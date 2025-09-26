# ==============================================================================
# ES5 Backend - Converts Solar directives (pure data) to CoffeeScript AST nodes
# ==============================================================================

class ES5Backend
  constructor: (@options = {}, @ast = {}) ->
    @cache = new Map()
    @currentDirective = null
    @currentRule = null

  # Helper to strip quotes from string literals
  _stripQuotes: (str) ->
    return str unless str?
    # Remove surrounding quotes if present
    if (str[0] in ['"', "'"]) and str[0] == str[str.length - 1]
      str.slice(1, -1)
    else
      str

  # Helper to ensure node has location data to avoid errors in AST operations
  _ensureLocationData: (node) ->
    if typeof node is 'object' and node isnt null
      node.locationData ?= {first_line: 0, first_column: 0, last_line: 0, last_column: 0, range: [0, 0]}
      node.updateLocationDataIfMissing?(node.locationData)
    node

  # Helper to convert primitive values to AST nodes
  _toNode: (value) ->
    return value if value instanceof @ast.Base
    return new @ast.IdentifierLiteral value if typeof value is 'string'
    return new @ast.NumberLiteral     value if typeof value is 'number'
    return new @ast.BooleanLiteral    value if typeof value is 'boolean'
    value

  # Helper to convert base + properties to Value node
  _toValue: (base, properties) ->
    props = if Array.isArray(properties) then properties else []

    # Handle existing Value
    if base instanceof @ast.Value
      base.add props if props.length
      return base

    # Ensure base is a node
    base = @_toNode(base) if base? and not (base instanceof @ast.Base)
    new @ast.Value base, props

  # Main entry point (called by parser as 'reduce')
  reduce: (values, positions, stackTop, symbolCount, directive) ->
    # Create lookup function to access stack values
    lookup = (index) -> values[stackTop - symbolCount + 1 + index]

    @currentDirective = directive
    @currentRule = directive
    @currentLookup = lookup  # Store lookup for use in $()

    # Create smart proxy that auto-resolves properties
    handler =
      get: (target, prop) ->
        # Return directive properties first
        return target[prop] if prop of target

        # Handle numeric indices for stack access
        if typeof prop is 'string' and /^\d+$/.test(prop)
          idx = parseInt(prop, 10) - 1  # Convert to 0-based
          return lookup(idx) if idx >= 0

        # Handle $N syntax
        if typeof prop is 'string' and prop[0] is '$'
          idx = parseInt(prop.slice(1), 10) - 1  # Convert to 0-based
          return lookup(idx) if idx >= 0

        undefined

    # Create smart directive object
    o = new Proxy directive, handler

    # Process the directive
    result = @process o

    if global.process?.env?.SOLAR_DEBUG
      util = require 'util'
      outName = result?.constructor?.name ? typeof result
      console.log "[Solar] result:", outName, util.inspect(result, {depth: 3, colors: true})

    result

  # Process a directive with smart resolution, ordered by most common to least
  process: (o) ->
    return @processAst o if o.$ast?
    return @processUse o if o.$use?
    return @processOps o if o.$ops?
    return @processArr o if o.$arr?
    @$ o

  # Smart resolver - handles all types of references
  $: (value) ->
    return value unless value?

    # Numbers are stack positions (1-based)
    if typeof value is 'number'
      return @currentLookup(value - 1) if @currentLookup
      return value

    # Arrays - resolve each item
    if Array.isArray value
      return value.map (item) => @$(item)

    # Objects with directives - process them
    if typeof value is 'object'
      return @process value if value.$ast or value.$ops or value.$use or value.$arr

      # Regular objects - resolve properties
      result = {}
      for own key, val of value
        result[key] = @$(val)
      return result

    # Everything else passes through
    value

  # Process $arr directives
  processArr: (o) ->
    items = @$(o.$arr)
    if Array.isArray(items) then items else [items]

  # Process $use directives
  processUse: (o) ->
    target = @$(o.$use)
    return target?[o.method]?() ?  target  if o.method?
    return target?[o.prop     ] ?  target  if o.prop?
    return target?[@$(o.index)] if target? if o.index?
    target

  # Process $ops directives
  processOps: (o) ->
    switch o.$ops
      when 'array'
        result = []
        if o.append?
          for item in o.append
            resolved = @$(item)
            if Array.isArray resolved
              result.push resolved...
            else if resolved?
              result.push resolved
        result

      when 'if'
        # Handle addElse operation for if-else chains
        if o.addElse?
          [ifNode, elseBody] = o.addElse.map (item) => @$(item)
          @_ensureLocationData ifNode
          @_ensureLocationData elseBody
          ifNode.addElse elseBody
          return ifNode

        # This shouldn't happen with current grammar
        console.warn "Unexpected $ops: 'if' without addElse"
        null

      when 'value'
        # Handle adding accessors to Values
        if o.add?
          [value, accessor] = o.add.map (item) => @$(item)
          if value instanceof @ast.Value
            return value.add accessor
          else
            return @_toValue value, [accessor]

        console.warn "Unexpected $ops: 'value' without add"
        null

      when 'loop'
        # Handle different loop operations
        if o.addSource?
          # addSource: [1, 2] means ForStart is at position 1, ForSource at position 2
          [loopNode, sourceInfo] = o.addSource.map (item) => @$(item)
          @_ensureLocationData loopNode
          @_ensureLocationData sourceInfo if sourceInfo?
          loopNode.addSource sourceInfo if loopNode?.addSource?
          return loopNode

        if o.addBody?
          # addBody: [1, 2] means loop is at position 1, body at position 2
          [loopNode, body] = o.addBody.map (item) => @$(item)

          # Handle "Body $N" placeholder strings
          if typeof body is 'string' and body.startsWith('Body $')
            idx = parseInt(body.slice(6)) - 1
            body = @currentDirective[idx + 1] if idx >= 0

          # Ensure body is a Block
          if not (body instanceof @ast.Block)
            body = new @ast.Block (if Array.isArray(body) then body else [body])

          @_ensureLocationData loopNode
          @_ensureLocationData body
          loopNode.addBody body
          return loopNode

        console.warn "Unknown loop operation:", o
        null

      else
        console.warn "Unknown $ops:", o.$ops
        null

  # Process $ast directives - the main AST node creation
  processAst: (o) ->
    switch o.$ast

      # Root, Block, and Splat
      when 'Root'
        body = @$(o.body)
        # Ensure body is a Block
        body = new @ast.Block [body] unless body instanceof @ast.Block
        body.makeReturn()
        new @ast.Root body
      when 'Block'
        expressions = @$(o.expressions)
        # Flatten if expressions is already a Block (from Body)
        expressions = expressions.expressions if expressions instanceof @ast.Block
        new @ast.Block expressions ? []
      when 'Splat' then new @ast.Splat @$(o.name), {postfix: @$(o.postfix)}

      # Literals
      when 'Literal'       then new @ast.Literal       @$(o.value)
      when 'NumberLiteral' then new @ast.NumberLiteral @$(o.value)
      when 'StringLiteral' then new @ast.StringLiteral @_stripQuotes(@$(o.value))
      when 'StringWithInterpolations'
        body = @$(o.body)
        new @ast.StringWithInterpolations switch
          when Array.isArray(body)        then new @ast.Block  body
          when body instanceof @ast.Block then body
          when body?                      then new @ast.Block [body]
          else                                 new @ast.Block []
      when 'BooleanLiteral'    then new @ast.BooleanLiteral    @$(o.value)
      when 'IdentifierLiteral' then new @ast.IdentifierLiteral @$(o.value)
      when 'PropertyName'      then new @ast.PropertyName      @$(o.value)
      when 'StatementLiteral'  then new @ast.StatementLiteral  @$(o.value)
      when 'ThisLiteral'       then new @ast.ThisLiteral
      when 'UndefinedLiteral'  then new @ast.UndefinedLiteral
      when 'NullLiteral'       then new @ast.NullLiteral
      when 'InfinityLiteral'   then new @ast.InfinityLiteral
      when 'NaNLiteral'        then new @ast.NaNLiteral

      # Value, Access, and Index
      when 'Value' then @_toValue @$(o.base), @$(o.properties) ? []
      when 'Access'
        name = @$(o.name)
        name = new @ast.PropertyName name.value if name instanceof @ast.IdentifierLiteral
        new @ast.Access name, @$(o.soak)
      when 'Index' then new @ast.Index @$(o.index)
      when 'Slice' then new @ast.Slice @$(o.range)

      # Operations
      when 'Op'
        # Process args - preserve undefineds for proper positioning
        args = o.args?.map((arg) => @$(arg)) or []
        if o.invertOperator? or o.originalOperator?
          options = {}
          options.invertOperator   = @$(o.invertOperator) if o.invertOperator?
          options.originalOperator = @$(o.originalOperator) if o.originalOperator?
          args.push options
        new @ast.Op args...

      when 'Assign'
        options = {}
        options.operatorToken = @$(o.operatorToken) if o.operatorToken
        new @ast.Assign @$(o.variable), @$(o.value), @$(o.context), options

      # Control Flow
      when 'If'
        condition = @_ensureLocationData @$(o.condition)
        body = @_ensureLocationData @$(o.body)
        ifNode = new @ast.If condition, body, {soak: @$(o.soak), postfix: @$(o.postfix)}
        if o.elseBody?
          elseBody = @_ensureLocationData @$(o.elseBody)
          ifNode.addElse elseBody
        ifNode

      when 'While'
        whileNode = new @ast.While @$(o.condition), {invert: @$(o.invert), guard: @$(o.guard)}
        whileNode.body ?= new @ast.Block []
        whileNode

      when 'For'
        # For loops are created and then extended via $ops: 'loop'
        body = @$(o.body) or []

        # Filter out empty objects from body (similar to Call args fix)
        if Array.isArray(body)
          body = body.filter (item) =>
            return false if item? and typeof item is 'object' and not (item instanceof @ast.Base) and Object.keys(item).length is 0
            true

        # Ensure body is a Block with location data
        body = new @ast.Block body unless body instanceof @ast.Block
        @_ensureLocationData body

        name = @$(o.name)
        index = @$(o.index)

        # Create the For node with name/index (source will be added via addSource)
        forNode = new @ast.For body, {name, index}
        forNode.await = @$(o.await) if o.await?
        forNode.own = @$(o.own) if o.own?
        forNode

      when 'Switch'     then new @ast.Switch @$(o.subject), @$(o.cases) or [], @$(o.otherwise)
      when 'When'       then new @ast.When   @$(o.conditions), @$(o.body)
      when 'SwitchWhen' then new @ast.When   @$(o.conditions), @$(o.body)

      # Collections
      when 'Obj'   then new @ast.Obj @$(o.properties) or [], @$(o.generated)
      when 'Arr'   then new @ast.Arr @$(o.objects) or []
      when 'Range' then new @ast.Range @$(o.from), @$(o.to), @$(o.exclusive)

      # Functions
      when 'Code'
        params = @$(o.params) or []
        body = @$(o.body)
        # Wrap body in Block if needed
        body = new @ast.Block(if Array.isArray(body) then body else [body]) unless body instanceof @ast.Block
        new @ast.Code params, body
      when 'Param'  then new @ast.Param  @$(o.name), @$(o.value), @$(o.splat)
      when 'Call'
        args = @$(o.args) or []
        # Filter out empty objects from Arguments rule (CALL_START CALL_END produces [{}])
        args = args.filter (arg) =>
          return false if arg? and typeof arg is 'object' and not (arg instanceof @ast.Base) and Object.keys(arg).length is 0
          true
        new @ast.Call @$(o.variable), args, @$(o.soak)
      when 'Return' then new @ast.Return @$(o.expression)
      when 'Yield'  then new @ast.Yield  @$(o.expression) or new @ast.Value(new @ast.Literal '')

      # Classes
      when 'Class'              then new @ast.Class              @$(o.variable), @$(o.parent), @$(o.body)
      when 'ClassProtoAssignOp' then new @ast.ClassProtoAssignOp @$(o.variable), @$(o.value)

      # Try/Catch/Throw
      when 'Try'   then new @ast.Try   @$(o.attempt), @$(o.errorVariable), @$(o.recovery), @$(o.ensure)
      when 'Catch'              then new @ast.Literal '# catch' #!# NOTE: Not implemented yet!
      when 'Throw' then new @ast.Throw @$(o.expression)

      # Other
      when 'Existence'         then new @ast.Existence         @$(o.expression)
      when 'Parens'            then new @ast.Parens            @$(o.body)
      when 'Expansion'         then new @ast.Expansion
      when 'ImportDeclaration' then new @ast.ImportDeclaration @$(o.clause), @$(o.source)
      when 'ExportDeclaration' then new @ast.ExportDeclaration @$(o.clause), @$(o.source), @$(o.default)

      # Additional types (temporary implementations)
      when 'PassthroughLiteral' then new @ast.Literal @$(o.value)
      when 'FuncGlyph'          then new @ast.Literal @$(o.value) or '->'
      when 'RegexLiteral'       then new @ast.Literal @$(o.value)
      when 'Interpolation'      then new @ast.Literal @$(o.expression) or ''

      else
        console.warn "Unknown $ast type:", o.$ast
        new @ast.Literal "# Missing AST node: #{o.$ast}"

module.exports = ES5Backend