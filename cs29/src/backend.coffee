# ==============================================================================
# Backend - Converts Solar directives (pure data) to CoffeeScript AST nodes
# ==============================================================================

class Backend
  constructor: (@options = {}, @ast = {}) ->
    @currentDirective = null
    @currentRule      = null
    @currentLookup    = null


  # Helper to convert base + properties to Value node
  _toValue: (base, properties) ->
    props = if Array.isArray(properties) then properties else []

    # Handle existing Value
    if base instanceof @ast.Value
      base.add props if props.length
      return base

    # In a properly working grammar, base should always be a node already
    new @ast.Value base, props

  # Main entry point (called by parser as 'reduce')
  reduce: (values, positions, stackTop, symbolCount, directive) ->
    # Create lookup function to access stack values
    lookup = (index) -> values[stackTop - symbolCount + 1 + index]

    # Create lookup function for position data
    lookupPos = (index) -> positions[stackTop - symbolCount + 1 + index]

    @currentDirective = directive
    @currentRule      = directive
    @currentLookup    = lookup  # Store lookup for use in $()
    @currentLookupPos = lookupPos  # Store position lookup

    # Get the location data for this production (combines all positions)
    if positions and symbolCount > 0
      firstPos = lookupPos(0)
      lastPos = lookupPos(symbolCount - 1)
      if firstPos and lastPos
        @currentLocationData =
          first_line: firstPos.first_line
          first_column: firstPos.first_column
          last_line_exclusive: lastPos.last_line_exclusive ? lastPos.last_line
          last_column_exclusive: lastPos.last_column_exclusive ? (lastPos.last_column + 1)
          range: [firstPos.range?[0] ? 0, lastPos.range?[1] ? 0]
    else
      @currentLocationData = null

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

    # Attach location data to the result if it's an AST node
    if result instanceof @ast.Base and @currentLocationData
      result.locationData = @currentLocationData
      result.updateLocationDataIfMissing?(@currentLocationData)

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

    # Arrays - resolve each item, filtering out undefined/null/non-nodes
    if Array.isArray value
      results = []
      for item in value
        resolved = @$(item)
        continue unless resolved?
        # ONLY include actual AST Base nodes
        # This prevents circular references and ensures arrays only contain proper nodes
        if resolved instanceof @ast.Base
          results.push resolved
      return results

    # Objects with directives - process them (but not null)
    if typeof value is 'object' and value?
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
    result = if Array.isArray(items) then items else [items]
    # Special handling for Arguments with implicit flag
    if o.implicit?
      implicit = @$(o.implicit)
      # In CoffeeScript, implicit defaults to true when generated is undefined or true
      # Only explicit calls (generated: false) have implicit: false
      result.implicit = implicit isnt false
    result

  # Process $use directives
  processUse: (o) ->
    target = @$(o.$use)
    return target?[o.method]?(o.args ? []...) if o.method?
    return target?[o.prop  ]                  if o.prop?
    return target?[o.index ]                  if o.index?
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
        return result

      when 'if'
        # Handle addElse operation for if-else chains
        if o.addElse?
          [ifNode, elseBody] = o.addElse.map (item) => @$(item)
          # Ensure elseBody has location data
          if elseBody and not elseBody.locationData and @currentLocationData
            elseBody.locationData = @currentLocationData
          ifNode.addElse elseBody
          return ifNode

      when 'value'
        # Handle adding accessors to Values
        if o.add?
          [value, accessor] = o.add.map (item) => @$(item)
          if value instanceof @ast.Value
            return value.add accessor
          else
            return @_toValue value, [accessor]

      when 'loop'
        # Handle different loop operations
        if o.addSource?
          # addSource: [1, 2] means ForStart is at position 1, ForSource at position 2
          [loopNode, sourceInfo] = o.addSource.map (item) => @$(item)
          loopNode.addSource sourceInfo if loopNode?.addSource?
          return loopNode

        if o.addBody?
          if global.process?.env?.SOLAR_DEBUG
            console.log "[Solar] loop.addBody operation:", o.addBody
          [loopNode, body] = o.addBody.map (item) => @$(item)
          body = @ast.Block.wrap body

          if global.process?.env?.SOLAR_DEBUG
            util = require 'util'
            console.log "[Solar] loop.addBody loopNode:", loopNode?.constructor?.name
            console.log "[Solar] loop.addBody body:", util.inspect(body, {depth: 2, colors: true})

          loopNode.addBody body
          loopNode.postfix = @$(o.postfix) if o.postfix?
          return loopNode

      when 'prop'
        # Handle property setting operations
        if o.set?
          target = @$(o.set.target)
          property = o.set.property
          value = @$(o.set.value)
          target[property] = value if target?
          return target

    # Catchall for any missing $ops directive handlers
    console.warn "Missing $ops directive handler:", o
    new @ast.Literal "# Missing $ops directive handler for: #{JSON.stringify(o)}"

  # Process $ast directives - the main AST node creation
  processAst: (o) ->
    switch o.$ast

      # === CORE EXPRESSIONS (Very High Frequency) ===

      # Values and property access - the most fundamental operations
      when 'Value'
        value = @_toValue @$(o.base), @$(o.properties) ? []
        value.this = true if o.this
        value
      when 'IdentifierLiteral'  then new @ast.IdentifierLiteral @$(o.value)
      when 'Literal'            then new @ast.Literal          @$(o.value)
      when 'NumberLiteral'      then new @ast.NumberLiteral    @$(o.value)
      when 'StringLiteral'
        new @ast.StringLiteral @$(o.value), {
          quote: @$(o.quote), initialChunk: @$(o.initialChunk), finalChunk: @$(o.finalChunk),
          indent: @$(o.indent), double: @$(o.double), heregex: @$(o.heregex)
        }

      # Basic operations - assignments, calls, operators
      when 'Assign'
        variable = @$(o.variable)
        value = @$(o.value)
        context = @$(o.context)
        # Mark @-based object-context assignments as static (for class bodies)
        variable.this = true if context is 'object' and variable instanceof @ast.Value and variable.base instanceof @ast.ThisLiteral
        # Handle compound assignment (+=, -=, etc.)
        operator = @$(o.operator) if o.operator?
        value = new @ast.Op operator.replace('=', ''), variable, value if operator and operator isnt '='
        options = if o.operatorToken then {operatorToken: @$(o.operatorToken)} else {}
        new @ast.Assign variable, value, context, options
      when 'Call'
        new @ast.Call @$(o.variable), @$(o.args) or [], @$(o.soak)
      when 'Op'
        # Process args - preserve undefineds for proper positioning
        args = o.args?.map((arg) => @$(arg)) or []
        if o.invertOperator? or o.originalOperator?
          options = {}
          options.invertOperator   = @$(o.invertOperator  ) if o.invertOperator?
          options.originalOperator = @$(o.originalOperator) if o.originalOperator?
          args.push options
        new @ast.Op args...

      # Property access patterns
      when 'Access'
        name = @$(o.name)
        name = new @ast.PropertyName name.value if name instanceof @ast.IdentifierLiteral
        new @ast.Access name, {soak: @$(o.soak), shorthand: @$(o.shorthand)}
      when 'Index'        then new @ast.Index        @$(o.index)
      when 'PropertyName' then new @ast.PropertyName @$(o.value)

      # === CONTROL FLOW & STRUCTURE (High Frequency) ===

      # Program structure
      when 'Block'
        expressions = @$(o.expressions)
        new @ast.Block (if expressions instanceof @ast.Block then expressions.expressions else expressions) or []
      when 'Root'
        body = @ast.Block.wrap @$(o.body)
        body.makeReturn() if @options.makeReturn
        new @ast.Root body

      # Control flow statements
      when 'If'
        ifNode = new @ast.If @$(o.condition), @ast.Block.wrap(@$(o.body)), {type: (if @$(o.invert) then 'unless' else @$(o.type)), postfix: @$(o.postfix)}
        ifNode.addElse @ast.Block.wrap(@$(o.elseBody)) if o.elseBody?
        ifNode
      when 'While'
        whileNode      = new @ast.While @$(o.condition), {invert: @$(o.invert), guard: @$(o.guard), isLoop: @$(o.isLoop)}
        whileNode.body = @ast.Block.wrap @$(o.body)
        whileNode
      when 'For'
        body = @ast.Block.wrap @$(o.body)
        forNode       = new @ast.For body, {name: @$(o.name), index: @$(o.index), source: @$(o.source)}
        forNode.await = @$(o.await) if o.await?
        forNode.own   = @$(o.own  ) if o.own?
        forNode
      when 'Return'
        new @ast.Return @$(o.expression)

      # === FUNCTIONS & CLASSES (Medium-High Frequency) ===

      when 'Code'      then new @ast.Code      @$(o.params) or [], @ast.Block.wrap(@$(o.body)), @$(o.funcGlyph), @$(o.paramStart)
      when 'FuncGlyph' then new @ast.FuncGlyph @$(o.glyph) or @$(o.value) or '->'
      when 'Class'     then new @ast.Class     @$(o.variable), @$(o.parent), @$(o.body)
      when 'Param'
        name = @$(o.name)
        name.this = true if name instanceof @ast.Value and name.base instanceof @ast.ThisLiteral
        new @ast.Param name, @$(o.value), @$(o.splat)

      # === DATA STRUCTURES (Medium Frequency) ===

      when 'Obj'       then new @ast.Obj       @$(o.properties) or [], @$(o.generated)
      when 'Arr'       then new @ast.Arr       @$(o.objects   ) or []
      when 'Range'     then new @ast.Range     @$(o.from), @$(o.to), if @$(o.exclusive) then 'exclusive'
      when 'Slice'     then new @ast.Slice     @$(o.range)
      when 'Expansion' then new @ast.Expansion  # Rest/spread operator (...)

      # === COMMON LITERALS (Medium Frequency) ===

      when 'BooleanLiteral'       then new @ast.BooleanLiteral       @$(o.value)
      when 'ThisLiteral'          then new @ast.ThisLiteral
      when 'NullLiteral'          then new @ast.NullLiteral
      when 'UndefinedLiteral'     then new @ast.UndefinedLiteral
      when 'RegexLiteral'         then new @ast.RegexLiteral         @$(o.value), {delimiter: @$(o.delimiter), heregexCommentTokens: @$(o.heregexCommentTokens)}
      when 'PassthroughLiteral'   then new @ast.PassthroughLiteral   @$(o.value), {here: @$(o.here), generated: @$(o.generated)}
      when 'StatementLiteral'     then new @ast.StatementLiteral     @$(o.value)
      when 'ComputedPropertyName' then new @ast.ComputedPropertyName @$(o.expression) or @$(o.name) or @$(o.value)

      # === STRING INTERPOLATION (Low-Medium Frequency) ===

      when 'StringWithInterpolations' then new @ast.StringWithInterpolations @ast.Block.wrap(@$(o.body))
      when 'Interpolation'
        expression = @$(o.expression)
        if expression? then new @ast.Interpolation expression else new @ast.EmptyInterpolation()

      # === SPECIAL OPERATIONS (Low Frequency) ===

      # Switch statements
      when 'Switch'     then new @ast.Switch     @$(o.subject), @$(o.cases) or [], @$(o.otherwise)
      when 'SwitchWhen' then new @ast.SwitchWhen [].concat(@$(o.conditions)), @$(o.body)

      # Super calls
      when 'Super'     then new @ast.Super     @$(o.accessor), @$(o.superLiteral)
      when 'SuperCall' then new @ast.SuperCall @$(o.variable), @$(o.args) or [], @$(o.soak)

      # Other operations
      when 'Existence' then new @ast.Existence @$(o.expression)
      when 'Parens'    then new @ast.Parens    @$(o.body)
      when 'Splat'     then new @ast.Splat     @$(o.name), {postfix: @$(o.postfix)}

      # === ERROR HANDLING (Low Frequency) ===

      when 'Try'   then new @ast.Try   @$(o.attempt), @$(o.catch), @$(o.ensure)
      when 'Catch' then new @ast.Catch @$(o.recovery) or @$(o.body), @$(o.variable) or @$(o.errorVariable)
      when 'Throw' then new @ast.Throw @$(o.expression)

      # === MODULES (Low Frequency) ===

      # Import statements
      when 'ImportDeclaration'        then new @ast.ImportDeclaration        @$(o.clause), @$(o.source)
      when 'ImportClause'             then new @ast.ImportClause             @$(o.defaultBinding), @$(o.namedImports)
      when 'ImportSpecifierList'      then new @ast.ImportSpecifierList      @$(o.specifiers) or []
      when 'ImportSpecifier'          then new @ast.ImportSpecifier          @$(o.imported), @$(o.local)
      when 'ImportDefaultSpecifier'   then new @ast.ImportDefaultSpecifier   @$(o.name) or @$(o.value) or @$(o)
      when 'ImportNamespaceSpecifier' then new @ast.ImportNamespaceSpecifier @$(o.star), @$(o.local)

      # Export statements
      when 'ExportNamedDeclaration'   then new @ast.ExportNamedDeclaration   @$(o.clause), @$(o.source), @$(o.assertions)
      when 'ExportDefaultDeclaration' then new @ast.ExportDefaultDeclaration @$(o.declaration) or @$(o.value)
      when 'ExportAllDeclaration'     then new @ast.ExportAllDeclaration     @$(o.exported), @$(o.source), @$(o.assertions)
      when 'ExportSpecifierList'      then new @ast.ExportSpecifierList      @$(o.specifiers) or []
      when 'ExportSpecifier'          then new @ast.ExportSpecifier          @$(o.value or o.local), @$(o.exported)

      # === ADVANCED/RARE FEATURES (Very Low Frequency) ===

      # Advanced literals
      when 'InfinityLiteral' then new @ast.InfinityLiteral
      when 'NaNLiteral'      then new @ast.NaNLiteral
      when 'DefaultLiteral'  then new @ast.DefaultLiteral @$(o.value) or 'default'

      # Advanced operations
      when 'YieldReturn'             then new @ast.YieldReturn             @$(o.expression), {returnKeyword: @$(o.returnKeyword)}
      when 'AwaitReturn'             then new @ast.AwaitReturn             @$(o.expression), {returnKeyword: @$(o.returnKeyword)}
      when 'DynamicImportCall'       then new @ast.DynamicImportCall       @$(o.variable), @$(o.args) or []
      when 'DynamicImport'           then new @ast.DynamicImport
      when 'TaggedTemplateCall'      then new @ast.TaggedTemplateCall      @$(o.variable), @$(o.template), @$(o.soak)
      when 'MetaProperty'            then new @ast.MetaProperty            @$(o.identifier), @$(o.accessor)
      when 'RegexWithInterpolations' then new @ast.RegexWithInterpolations @$(o.invocation), {heregexCommentTokens: @$(o.heregexCommentTokens)}

      # Rare array operation
      when 'Elision' then new @ast.Elision  # Sparse array holes

      else
        console.warn "Unknown $ast type:", o.$ast
        new @ast.Literal "# Missing AST node: #{o.$ast}"

module.exports = Backend
