# ==============================================================================
# ES5 Backend - Solar Directive Processor for CoffeeScript
# ==============================================================================
#
# Converts Solar directives (pure data) to CoffeeScript AST node instances
# This clean implementation uses smart proxies for automatic resolution
# ==============================================================================

class ES5Backend
  constructor: (@options = {}, @ast = {}) ->
    @cache = new Map()
    @currentDirective = null
    @currentType = null
    @currentRule = null

  # Add minimal location data to node to avoid errors in AST operations
  _addLocationData: (node) ->
    if typeof node is 'object' and node isnt null
      node.locationData ?= {first_line: 0, first_column: 0, last_line: 0, last_column: 0, range: [0, 0]}
      node.updateLocationDataIfMissing?(node.locationData)
    node

  # Filter null/undefined nodes from an array
  _filterNodes: (nodes) ->
    return [] unless nodes?
    if Array.isArray nodes
      nodes.filter (n) -> n?
    else if nodes?
      [nodes]
    else
      []

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

  # Process a directive with smart resolution
  process: (o) ->
    # Handle special directive types
    if o.$ops?
      return @processOps o

    if o.$use?
      return @processUse o

    if o.$ary?
      items = @$(o.$ary)
      return if Array.isArray(items) then items else [items]

    if o.$ast?
      return @processAst o

    # For regular values, just resolve
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
          @_addLocationData ifNode
          @_addLocationData elseBody
          ifNode.addElse elseBody
        ifNode

      when 'loop'
        switch o.type
          when 'addSource'
            loopNode = @$(o.loop)
            sourceInfo = @$(o.source)
            @_addLocationData loopNode
            @_addLocationData sourceInfo
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
              body = new @ast.Block @_filterNodes(if Array.isArray(body) then body else [body])

            @_addLocationData loopNode
            @_addLocationData body
            loopNode.addBody body
            loopNode

          else
            console.warn "Unknown loop operation:", o.type
            null

      else
        console.warn "Unknown $ops:", o.$ops
        null

  # Process $use directives
  processUse: (o) ->
    target = @$(o.$use)

    if o.method?
      return target?[o.method]?() ? target

    if o.prop?
      return target?[o.prop] ? target

    if o.index?
      idx = @$(o.index)
      return target?[idx] if target?

    target

  # Process $ast directives - the main AST node creation
  processAst: (o) ->
    switch o.$ast
      when '@'
        # Pass-through directives that use the node type from context
        switch @currentType
          when 'Root'
            body = @$(o.body)
            # Wrap array in Block if needed
            body = new @ast.Block(body) if Array.isArray(body)
            new @ast.Root body

          when 'Block'
            new @ast.Block @$(o.expressions) or []

          when 'Splat'
            new @ast.Splat @$(o.name), {postfix: @$(o.postfix)}

          else
            console.warn "Unknown @ node type:", @currentType
            null

      # Literals
      when 'Literal'             then new @ast.Literal              @$(o.value)
      when 'NumberLiteral'       then new @ast.NumberLiteral        @$(o.value)
      when 'StringLiteral'       then new @ast.StringLiteral        @$(o.value)
      when 'StringWithInterpolations' then new @ast.StringWithInterpolations @$(o.body)
      when 'BooleanLiteral'      then new @ast.BooleanLiteral       @$(o.value)
      when 'IdentifierLiteral'   then new @ast.IdentifierLiteral    @$(o.value)
      when 'PropertyName'        then new @ast.PropertyName         @$(o.value)
      when 'StatementLiteral'    then new @ast.StatementLiteral     @$(o.value)
      when 'ThisLiteral'         then new @ast.ThisLiteral
      when 'UndefinedLiteral'    then new @ast.UndefinedLiteral
      when 'NullLiteral'         then new @ast.NullLiteral
      when 'InfinityLiteral'     then new @ast.InfinityLiteral
      when 'NaNLiteral'          then new @ast.NaNLiteral

      # Value and Access
      when 'Value'
        base = @$(o.base) ? @$(o.value) ? @$(o.val)
        props = @$(o.properties) ? []
        @_buildValue base, props

      when 'Access'
        name = @$(o.name)
        name = new @ast.PropertyName name.value if name instanceof @ast.IdentifierLiteral
        new @ast.Access name, @$(o.soak)

      when 'Index'
        new @ast.Index @$(o.index)

      # Operations
      when 'Op'
        args = o.args.map (arg) => @$(arg)
        if o.invertOperator? or o.originalOperator?
          options = {}
          options.invertOperator = @$(o.invertOperator) if o.invertOperator?
          options.originalOperator = @$(o.originalOperator) if o.originalOperator?
          args.push options
        new @ast.Op args...

      when 'Assign'
        new @ast.Assign @$(o.variable), @$(o.value), @$(o.operator)

      # Control Flow
      when 'If'
        ifNode = new @ast.If @$(o.condition), @$(o.body), {soak: @$(o.soak), postfix: @$(o.postfix)}
        if o.elseBody?
          elseBody = @$(o.elseBody)
          @_addLocationData ifNode
          @_addLocationData elseBody
          ifNode.addElse elseBody
        ifNode

      when 'While'
        whileNode = new @ast.While @$(o.condition), {invert: @$(o.invert), guard: @$(o.guard)}
        whileNode.body ?= new @ast.Block []
        whileNode

      when 'For'
        name = @_ensureNode @$(o.name)
        index = @_ensureNode(@$(o.index)) if o.index?
        new @ast.For name, @$(o.source), index

      when 'Switch'
        new @ast.Switch @$(o.subject), @$(o.cases) or [], @$(o.otherwise)

      when 'When'
        new @ast.When @$(o.conditions), @$(o.body)

      # Collections
      when 'Obj'
        new @ast.Obj @$(o.properties) or [], @$(o.generated)

      when 'Arr'
        new @ast.Arr @$(o.objects) or []

      when 'Range'
        exclusive = if @$(o.exclusive) then 'exclusive' else null
        new @ast.Range @$(o.from), @$(o.to), exclusive

      # Functions
      when 'Code'
        new @ast.Code @$(o.params) or [], @$(o.body)

      when 'Param'
        new @ast.Param @$(o.name), @$(o.value), @$(o.splat)

      when 'Call'
        new @ast.Call @$(o.variable), @$(o.args) or [], @$(o.soak)

      when 'Return'
        new @ast.Return @$(o.expression)

      when 'Yield'
        expression = @$(o.expression)
        expression = new @ast.Value(new @ast.Literal '') unless expression?
        new @ast.Yield expression

      # Root (special case)
      when 'Root'
        body = @$(o.body)
        # Wrap array in Block if needed
        body = new @ast.Block(body) if Array.isArray(body)
        new @ast.Root body

      # Classes
      when 'Class'
        new @ast.Class @$(o.variable), @$(o.parent), @$(o.body)

      when 'ClassProtoAssignOp'
        new @ast.ClassProtoAssignOp @$(o.variable), @$(o.value)

      # Try/Catch
      when 'Try'
        new @ast.Try @$(o.attempt), @$(o.errorVariable), @$(o.recovery), @$(o.ensure)

      # Other
      when 'Existence'
        new @ast.Existence @$(o.expression)

      when 'Parens'
        new @ast.Parens @$(o.body)

      when 'Expansion'
        new @ast.Expansion

      when 'ImportDeclaration'
        new @ast.ImportDeclaration @$(o.clause), @$(o.source)

      when 'ExportDeclaration'
        new @ast.ExportDeclaration @$(o.clause), @$(o.source), @$(o.default)

      else
        console.warn "Unknown $ast type:", o.$ast
        null

  # Build a Value from base + properties
  _buildValue: (base, properties) ->
    if base instanceof @ast.Value
      props = @_filterNodes (if Array.isArray(properties) then properties else [])
      base.add props if props.length
      return base

    base = @_ensureNode(base) if base? and not (base instanceof @ast.Base)
    props = @_filterNodes (if Array.isArray(properties) then properties else [])

    if props.length
      new @ast.Value base, props
    else
      new @ast.Value base

  # Helper to ensure value is a proper node
  _ensureNode: (value) ->
    return value if value instanceof @ast.Base
    return new @ast.IdentifierLiteral value if typeof value is 'string'
    return new @ast.NumberLiteral value if typeof value is 'number'
    return new @ast.BooleanLiteral value if typeof value is 'boolean'
    value

module.exports = ES5Backend