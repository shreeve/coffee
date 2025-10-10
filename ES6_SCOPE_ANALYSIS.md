# ES6 Scope Analysis with Solar Directives

## The Problem

CoffeeScript's ES6 mode has systematic scoping issues:
1. Variables declared in try blocks aren't accessible outside
2. Helper functions get renamed (indexOf1, indexOf2, etc.)
3. Loop comprehensions don't declare their result variables
4. Implicit returns create undeclared variables

## Two-Pass Solution with Solar Directives

### Pass 1: Variable Analysis
Using Solar directives, we can traverse the AST and:
1. Track all variable declarations and their scopes
2. Track all variable usages and their scopes
3. Identify variables that escape their declaring scope
4. Mark variables as `const` or `let` based on reassignment

### Pass 2: Variable Promotion and Declaration
Based on the analysis:
1. Promote variables declared in try blocks if used outside
2. Declare all implicit variables at the appropriate scope level
3. Use `const` for variables that are never reassigned
4. Use `let` for variables that are reassigned

## Implementation Strategy

### 1. Try/Catch Variable Promotion

```coffeescript
# In nodes.coffee, add to Try class:
analyzeVariables: (o) ->
  tryVars = []

  # Collect variables declared in try block
  @attempt.traverseChildren no, (node) ->
    if node instanceof Assign and node.variable instanceof IdentifierLiteral
      tryVars.push node.variable.value

  # Check if used in catch/ensure or after
  usedOutside = []
  for varName in tryVars
    if @catch?.contains((n) -> n instanceof IdentifierLiteral and n.value is varName)
      usedOutside.push varName
    if @ensure?.contains((n) -> n instanceof IdentifierLiteral and n.value is varName)
      usedOutside.push varName

  # Promote variables used outside
  for varName in usedOutside
    o.scope.add varName, 'let'

  usedOutside

compileNode: (o) ->
  # Analyze and promote variables first
  promotedVars = @analyzeVariables(o)

  # Declare promoted variables before try block
  declarations = []
  for varName in promotedVars
    declarations.push @makeCode "let #{varName};\n#{@tab}"

  # ... rest of compilation
```

### 2. Helper Function Management

```coffeescript
# In nodes.coffee, modify utility function:
utility = (name, o) ->
  {root} = o.scope

  # Check if utility already exists at module level
  if root.utilities?[name]
    return root.utilities[name]

  # Create once at module level
  ref = "$$#{name}"  # Use special prefix to avoid conflicts
  root.utilities ?= {}
  root.utilities[name] = ref
  root.assign ref, UTILITIES[name] o
  ref
```

### 3. Comprehensive Variable Declaration

```coffeescript
# Add to Scope class:
analyzeVariableUsage: ->
  assignments = {}
  usages = {}

  # Track all assignments and usages
  @expressions.traverseChildren yes, (node) ->
    if node instanceof Assign
      varName = node.variable.unwrap().value if node.variable instanceof IdentifierLiteral
      assignments[varName] ?= []
      assignments[varName].push node

    if node instanceof IdentifierLiteral and not node.isAssignable()
      usages[node.value] ?= []
      usages[node.value].push node

  # Determine const vs let
  for varName, assignList of assignments
    if assignList.length > 1
      @add varName, 'let'
    else
      @add varName, 'const'
```

## Benefits of Solar Directives Approach

1. **Static Analysis**: Solar directives provide complete AST information before code generation
2. **Scope Awareness**: Can track variables across scope boundaries
3. **Reassignment Detection**: Can determine if a variable is reassigned to choose const/let
4. **Clean Separation**: Analysis phase is separate from code generation

## Implementation Priority

1. **Fix try/catch scoping** - Most common issue
2. **Fix helper functions** - Affects all code using `in`, `of`, etc.
3. **Fix implicit variables** - Comprehensions, destructuring, etc.
4. **Optimize const/let usage** - Performance and correctness
