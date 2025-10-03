# ==============================================================================
# Backend - Converts Solar directives (pure data) to CoffeeScript AST nodes
# ==============================================================================

class Backend
  constructor: (@options = {}, @ast = {}) ->

  # Helper to set location data for a node
  _toLocation: (pos) ->
    if Array.isArray(pos)
      from = @pos pos[0]
      till = @pos pos[1]
    else if typeof pos is 'number'
      from = till = @pos pos

    if from and till
      first_line:            from.first_line
      first_column:          from.first_column
      last_line_exclusive:   till.last_line_exclusive   ?  till.last_line
      last_column_exclusive: till.last_column_exclusive ? (till.last_column + 1)
      range:                [from.range?[0] ? 0, till.range?[1] ? 0]

  # Helper to convert base + properties to Value node
  _toValue: (base, properties, tag = null, isDefaultValue = false) ->
    props = if Array.isArray(properties) then properties else []

    # Handle existing Value
    if base instanceof @ast.Value
      base.add props if props.length
      return base

    # Base should already be a node
    new @ast.Value base, props, tag, isDefaultValue

  # Parser reducer: call as r(...) = reduce(values, positions, stackTop, ...)
  # Called ONCE per grammar rule match (e.g., 'TRY Block FINALLY Block'). This
  # sets @loc (current location) to span the ENTIRE rule (first to last token).
  # All AST nodes created during this call inherit this rule-wide location info
  # unless manually overridden. Without any override, a 'finally' keyword would
  # incorrectly span the entire try/finally block. This is why Literal is the
  # only AST type used to capture raw tokens by position (e.g., finallyTag,
  # operatorToken, returnKeyword).
  reduce: (values, positions, stackTop, symbolCount, directive) ->
    @tok = (pos) ->    values[stackTop - symbolCount + pos] # 1-based index
    @pos = (pos) -> positions[stackTop - symbolCount + pos] # 1-based index
    @loc = @_toLocation [1, symbolCount] if positions and symbolCount > 0

    # Create a smart directive proxy that can auto-resolve its properties
    o = new Proxy directive, get: (target, prop) =>
      return target[prop]                  if prop of target   # props first
      return @tok(parseInt(prop     , 10)) if /^\d+$/.test(prop) # token index
      return @tok(parseInt(prop[1..], 10)) if prop[0] is '$'     # $N syntax
      return undefined # not needed, but just to be obvious

    # Process the directive
    result = @process o

    # Only set if missing - don't overwrite!
    if result instanceof @ast.Base and not result.locationData and @loc
      result.locationData = @loc

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

    # Numbers are token positions (1-based)
    if typeof value is 'number'
      return @tok(value)

    # Arrays - resolve each item, filtering out undefined/null/non-nodes
    if Array.isArray value
      results = []
      for item in value
        resolved = @$(item)
        continue unless resolved?
        if resolved instanceof @ast.Base
          results.push resolved
      return results

    # Process objects with directives
    if typeof value is 'object' and value?
      return @process value if value.$ast or value.$ops or value.$use or value.$arr
      result = {}
      result[key] = @$(val) for own key, val of value
      return result

    # Everything else passes through
    value

  # Process $arr directives
  processArr: (o) ->
    items = @$(o.$arr)
    result = if Array.isArray(items) then items else [items]
    result.implicit = !!@$(o.implicit) if o.implicit?
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

      # Handle array operations
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

      # Handle addElse operation for if-else chains
      when 'if'
        if o.addElse?
          [ifNode, elseBody] = o.addElse.map (item) => @$(item)
          if elseBody and not elseBody.locationData and @loc
            elseBody.locationData = @loc
          ifNode.addElse elseBody
          return ifNode

      # Handle adding accessors to Values
      when 'value'
        if o.add?
          [value, accessor] = o.add.map (item) => @$(item)
          if value instanceof @ast.Value
            return value.add accessor
          else
            return @_toValue value, [accessor]

      # Handle different loop operations
      when 'loop'
        if o.addSource?
          [loopNode, sourceInfo] = o.addSource.map (item) => @$(item)
          loopNode.addSource sourceInfo if loopNode?.addSource?
          return loopNode

        if o.addBody?
          [loopNode, body] = o.addBody.map (item) => @$(item)
          loopNode.addBody @ast.Block.wrap(body)
          loopNode.postfix = @$(o.postfix) if o.postfix?
          return loopNode

      # Handle property setting operations
      when 'prop'
        if o.set?
          target = @$(o.set.target)
          value  = @$(o.set.value )
          target[o.set.property] = value if target?
          return target

    # Catchall for any missing $ops directive handlers
    console.warn "Missing $ops directive handler:", o
    new @ast.Literal "# Missing $ops directive handler for: #{JSON.stringify(o)}"

  # Process $ast directives - the main AST node creation
  processAst: (o) ->
    node = switch o.$ast

      # === CORE EXPRESSIONS (Very High Frequency) ===

      # Values and property access - the most fundamental operations
      when 'Value'             then @_toValue @$(o.base), @$(o.properties) ? [], (o.this and 'this'), @$(o.isDefaultValue) ? false
      when 'IdentifierLiteral' then new @ast.IdentifierLiteral @$(o.value)
      when 'NumberLiteral'     then new @ast.NumberLiteral     @$(o.value), {parsedValue: @$(o.parsedValue)}
      when 'Literal' # Literal location data maps to just one token in the rule
        node = new @ast.Literal @$(pos = o.value)
        node.locationData = @_toLocation(pos) if typeof pos is 'number'
        node
      when 'StringLiteral'
        new @ast.StringLiteral @$(o.value), {
          quote: @$(o.quote), initialChunk: @$(o.initialChunk), finalChunk: @$(o.finalChunk),
          indent: @$(o.indent), double: @$(o.double), heregex: @$(o.heregex)
        }

      # Basic operations - assignments, calls, operators
      when 'Assign'
        variable   = @$(o.variable)
        operator   = @$(o.operator)
        value      = @$(o.value   )
        context    = @$(o.context )
        variable.this = true if context is 'object' and variable instanceof @ast.Value and variable.base instanceof @ast.ThisLiteral
        # Only expand special compound assignments that JS doesn't support natively
        # Standard compound assignments like +=, -=, *=, /=, etc. should be preserved
        if operator in ['//=', '%%=']
          value = new @ast.Op operator[...-1], variable, value
          context = '='
        else if operator and operator not in ['=', '?=', undefined]
          # For standard compound assignments, preserve them by setting context
          context = operator
        else if operator is '?='
          context = operator
        options    = {}
        options[k] = @$(o[k]) for k in ['operatorToken', 'moduleDeclaration', 'originalContext'] when o[k]?
        new @ast.Assign variable, value, context, options
      when 'Call'
        new @ast.Call @$(o.variable), @$(o.args) or [], @$(o.soak)
      when 'Op'
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
        body       = @ast.Block.wrap @$(o.body)
        forNode    = new @ast.For body, {name: @$(o.name), index: @$(o.index), source: @$(o.source)}
        forNode[k] = @$(o[k]) for k in ['await', 'awaitTag', 'own', 'ownTag', 'step', 'from', 'object', 'guard'] when o[k]?
        forNode
      when 'Return'
        new @ast.Return @$(o.expression)

      # === FUNCTIONS & CLASSES (Medium-High Frequency) ===

      when 'Code'                     then new @ast.Code      @$(o.params) or [], @ast.Block.wrap(@$(o.body)), @$(o.funcGlyph), @$(o.paramStart)
      when 'FuncGlyph'                then new @ast.FuncGlyph @$(o.glyph) or @$(o.value) or '->'
      when 'Class'                    then new @ast.Class     @$(o.variable), @$(o.parent), @$(o.body)
      when 'Param'
        name = @$(o.name)
        name.this = true if name instanceof @ast.Value and name.base instanceof @ast.ThisLiteral
        new @ast.Param name, @$(o.value), @$(o.splat)

      # === DATA STRUCTURES (Medium Frequency) ===

      when 'Obj'                      then new @ast.Obj       @$(o.properties) or [], @$(o.generated)
      when 'Arr'                      then new @ast.Arr       @$(o.objects   ) or []
      when 'Range'                    then new @ast.Range     @$(o.from), @$(o.to), if @$(o.exclusive) then 'exclusive'
      when 'Slice'                    then new @ast.Slice     @$(o.range)
      when 'Expansion'                then new @ast.Expansion # Rest/spread operator (...)

      # === COMMON LITERALS (Medium Frequency) ===

      when 'BooleanLiteral'           then new @ast.BooleanLiteral       @$(o.value), {originalValue: @$(o.originalValue)}
      when 'ThisLiteral'              then new @ast.ThisLiteral          @$(o.value)
      when 'NullLiteral'              then new @ast.NullLiteral
      when 'UndefinedLiteral'         then new @ast.UndefinedLiteral
      when 'RegexLiteral'             then new @ast.RegexLiteral         @$(o.value), {delimiter: @$(o.delimiter), heregexCommentTokens: @$(o.heregexCommentTokens)}
      when 'PassthroughLiteral'       then new @ast.PassthroughLiteral   @$(o.value), {here: @$(o.here), generated: @$(o.generated)}
      when 'StatementLiteral'         then new @ast.StatementLiteral     @$(o.value)
      when 'ComputedPropertyName'     then new @ast.ComputedPropertyName @$(o.value)

      # === STRING INTERPOLATION (Low-Medium Frequency) ===

      when 'StringWithInterpolations' then new @ast.StringWithInterpolations @ast.Block.wrap(@$(o.body)), {quote: @$(o.quote), startQuote: @$(o.startQuote)}
      when 'Interpolation'
        expression = @$(o.expression)
        if expression? then new @ast.Interpolation expression else new @ast.EmptyInterpolation()

      # === SPECIAL OPERATIONS (Low Frequency) ===

      # Switch statements
      when 'Switch'                   then new @ast.Switch     @$(o.subject), @$(o.cases) or [], @$(o.otherwise)
      when 'SwitchWhen'               then new @ast.SwitchWhen [].concat(@$(o.conditions)), @$(o.body)

      # Super calls
      when 'Super'                    then new @ast.Super     @$(o.accessor), @$(o.superLiteral)
      when 'SuperCall'                then new @ast.SuperCall @$(o.variable), @$(o.args) or [], @$(o.soak)

      # Other operations
      when 'Existence'                then new @ast.Existence @$(o.expression)
      when 'Parens'                   then new @ast.Parens    @$(o.body)
      when 'Splat'                    then new @ast.Splat     @$(o.name), {postfix: @$(o.postfix)}

      # === ERROR HANDLING (Low Frequency) ===

      when 'Try'                      then new @ast.Try   @$(o.attempt ), @$(o.catch), @$(o.ensure), @$(o.finallyTag)
      when 'Catch'                    then new @ast.Catch @$(o.recovery), @$(o.variable) or @$(o.errorVariable)
      when 'Throw'                    then new @ast.Throw @$(o.expression)

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
      when 'InfinityLiteral'          then new @ast.InfinityLiteral
      when 'NaNLiteral'               then new @ast.NaNLiteral
      when 'DefaultLiteral'           then new @ast.DefaultLiteral @$(o.value) or 'default'

      # Advanced operations
      when 'YieldReturn'              then new @ast.YieldReturn             @$(o.expression), {returnKeyword: @$(o.returnKeyword)}
      when 'AwaitReturn'              then new @ast.AwaitReturn             @$(o.expression), {returnKeyword: @$(o.returnKeyword)}
      when 'DynamicImportCall'        then new @ast.DynamicImportCall       @$(o.variable), @$(o.args) or []
      when 'DynamicImport'            then new @ast.DynamicImport
      when 'TaggedTemplateCall'       then new @ast.TaggedTemplateCall      @$(o.variable), @$(o.template), @$(o.soak)
      when 'MetaProperty'             then new @ast.MetaProperty            @$(o.identifier), @$(o.accessor)
      when 'RegexWithInterpolations'  then new @ast.RegexWithInterpolations @$(o.invocation), {heregexCommentTokens: @$(o.heregexCommentTokens)}

      # Rare array operation
      when 'Elision'                  then new @ast.Elision  # Sparse array holes

      else
        console.warn "Unknown $ast type:", o.$ast
        new @ast.Literal "# Missing AST node: #{o.$ast}"

    # Possibly override AST node location data
    if node instanceof @ast.Base
      if (pos = o.$pos)? and loc = @_toLocation(pos)
        node.locationData = loc
      else if not node.locationData and @loc
        node.locationData = @loc

    node

module.exports = Backend
