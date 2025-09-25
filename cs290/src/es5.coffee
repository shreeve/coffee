# ==============================================================================
# ES5 Backend - Converts Solar directives (pure data) to CoffeeScript AST nodes
# ==============================================================================

class ES5Backend
  constructor: (@options = {}, @ast = {}) ->
    @cache = new Map()
    @currentDirective = null
    @currentType = null
    @currentRule = null

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
    @currentType = directive?.$ast
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

    if process?.env?.SOLAR_DEBUG
      util = require 'util'
      outName = result?.constructor?.name ? typeof result
      console.log "[Solar] result:", outName, util.inspect(result, {depth: 3, colors: true})

    result

  # Process a directive with smart resolution, ordered by most common to least
  process: (o) ->
    return @processAst o if o.$ast?
    return @processUse o if o.$use?
    return @processOps o if o.$ops?
    return @processAry o if o.$ary?
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
      return @process value if value.$ast or value.$ops or value.$use or value.$ary

      # Regular objects - resolve properties
      result = {}
      for own key, val of value
        result[key] = @$(val)
      return result

    # Everything else passes through
    value

  # Process $ary directives
  processAry: (o) ->
    items = @$(o.$ary)
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
        ifNode = new @ast.If @$(o.condition), @$(o.body), {soak: @$(o.soak), postfix: @$(o.postfix)}
        if o.elseBody?
          elseBody = @$(o.elseBody)
          @_ensureLocationData ifNode
          @_ensureLocationData elseBody
          ifNode.addElse elseBody
        ifNode

      when 'loop'
        switch o.type
          when 'addSource'
            loopNode = @$(o.loop)
            sourceInfo = @$(o.source)
            @_ensureLocationData loopNode
            @_ensureLocationData sourceInfo
            loopNode.addSource sourceInfo
            loopNode

          when 'addBody'
            loopNode = @$(o.loop)
            body = @$(o.body)

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
            loopNode

          else
            console.warn "Unknown loop operation:", o.type
            null

      else
        console.warn "Unknown $ops:", o.$ops
        null

  # Process $ast directives - the main AST node creation
  processAst: (o) ->
    switch o.$ast

      # Pass-through directives that use the node type from context
      when '@'
        switch @currentType
          when 'Root'
            body = @$(o.body)
            body = new @ast.Block(body) if Array.isArray(body)
            new @ast.Root body
          when 'Block' then new @ast.Block @$(o.expressions) or []
          when 'Splat' then new @ast.Splat @$(o.name), {postfix: @$(o.postfix)}
          else
            console.warn "Unknown @ node type:", @currentType
            null

      # Literals
      when 'Literal'                  then new @ast.Literal                  @$(o.value)
      when 'NumberLiteral'            then new @ast.NumberLiteral            @$(o.value)
      when 'StringLiteral'            then new @ast.StringLiteral            @$(o.value)
      when 'StringWithInterpolations' then new @ast.StringWithInterpolations @$(o.body)
      when 'BooleanLiteral'           then new @ast.BooleanLiteral           @$(o.value)
      when 'IdentifierLiteral'        then new @ast.IdentifierLiteral        @$(o.value)
      when 'PropertyName'             then new @ast.PropertyName             @$(o.value)
      when 'StatementLiteral'         then new @ast.StatementLiteral         @$(o.value)
      when 'ThisLiteral'              then new @ast.ThisLiteral
      when 'UndefinedLiteral'         then new @ast.UndefinedLiteral
      when 'NullLiteral'              then new @ast.NullLiteral
      when 'InfinityLiteral'          then new @ast.InfinityLiteral
      when 'NaNLiteral'               then new @ast.NaNLiteral

      # Value and Access
      when 'Value'
        @_toValue @$(o.base), @$(o.properties) ? []

      when 'Access'
        name = @$(o.name)
        name = new @ast.PropertyName name.value if name instanceof @ast.IdentifierLiteral
        new @ast.Access name, @$(o.soak)

      when 'Index' then new @ast.Index @$(o.index)

      # Operations
      when 'Op'
        args = o.args.map (arg) => @$(arg)
        if o.invertOperator? or o.originalOperator?
          options = {}
          options.invertOperator = @$(o.invertOperator) if o.invertOperator?
          options.originalOperator = @$(o.originalOperator) if o.originalOperator?
          args.push options
        new @ast.Op args...

      when 'Assign' then new @ast.Assign @$(o.variable), @$(o.value), @$(o.operator)

      # Control Flow
      when 'If'
        ifNode = new @ast.If @$(o.condition), @$(o.body), {soak: @$(o.soak), postfix: @$(o.postfix)}
        if o.elseBody?
          elseBody = @$(o.elseBody)
          @_ensureLocationData ifNode
          @_ensureLocationData elseBody
          ifNode.addElse elseBody
        ifNode

      when 'While'
        whileNode = new @ast.While @$(o.condition), {invert: @$(o.invert), guard: @$(o.guard)}
        whileNode.body ?= new @ast.Block []
        whileNode

      when 'For'
        name = @_toNode @$(o.name)
        index = @_toNode(@$(o.index)) if o.index?
        new @ast.For name, @$(o.source), index

      when 'Switch' then new @ast.Switch @$(o.subject), @$(o.cases) or [], @$(o.otherwise)
      when 'When'   then new @ast.When   @$(o.conditions), @$(o.body)

      # Collections
      when 'Obj' then new @ast.Obj @$(o.properties) or [], @$(o.generated)
      when 'Arr' then new @ast.Arr @$(o.objects) or []
      when 'Range'
        exclusive = if @$(o.exclusive) then 'exclusive' else null
        new @ast.Range @$(o.from), @$(o.to), exclusive

      # Functions
      when 'Code'   then new @ast.Code   @$(o.params) or [], @$(o.body)
      when 'Param'  then new @ast.Param  @$(o.name), @$(o.value), @$(o.splat)
      when 'Call'   then new @ast.Call   @$(o.variable), @$(o.args) or [], @$(o.soak)
      when 'Return' then new @ast.Return @$(o.expression)

      when 'Yield'
        expression = @$(o.expression)
        expression = new @ast.Value(new @ast.Literal '') unless expression?
        new @ast.Yield expression

      # Root and Block
      when 'Root'
        body = @$(o.body)
        # Wrap array in Block if needed
        body = new @ast.Block(body) if Array.isArray(body)
        new @ast.Root body

      when 'Block' then new @ast.Block @$(o.expressions) ? []

      # Classes
      when 'Class'              then new @ast.Class              @$(o.variable), @$(o.parent), @$(o.body)
      when 'ClassProtoAssignOp' then new @ast.ClassProtoAssignOp @$(o.variable), @$(o.value)

      # Try/Catch
      when 'Try' then new @ast.Try @$(o.attempt), @$(o.errorVariable), @$(o.recovery), @$(o.ensure)

      # Other
      when 'Existence'         then new @ast.Existence         @$(o.expression)
      when 'Parens'            then new @ast.Parens            @$(o.body)
      when 'Expansion'         then new @ast.Expansion
      when 'ImportDeclaration' then new @ast.ImportDeclaration @$(o.clause), @$(o.source)
      when 'ExportDeclaration' then new @ast.ExportDeclaration @$(o.clause), @$(o.source), @$(o.default)

      else
        console.warn "Unknown $ast type:", o.$ast
        null

module.exports = ES5Backend