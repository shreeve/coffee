# Solar Two-Pass Implementation for ES6 Scoping

## Overview
This implementation uses Solar directives to perform comprehensive variable analysis in two passes:
1. **Discovery Pass**: Traverse AST to find all variable uses and assignments
2. **Declaration Pass**: Determine optimal declaration locations and const/let keywords

## Implementation Plan

### Phase 1: Variable Discovery
Create a Solar directive that traverses the AST and collects:
- All variable assignments (location, scope, value type)
- All variable references (location, scope)
- Special contexts (try/catch, loops, conditionals)

### Phase 2: Declaration Analysis
Using collected data, determine:
- Which variables need promotion (try/catch, conditionals)
- Which can be `const` (never reassigned)
- Which must be `let` (reassigned or loop variables)
- Optimal declaration location (minimize scope while avoiding TDZ)

## Code Implementation

```coffeescript
# Add to nodes.coffee

export class SolarScopeAnalyzer
  constructor: (@root) ->
    @variables = {}  # varName -> {assignments: [], references: [], scopes: []}
    @scopes = []     # Stack of current scopes during traversal

  analyze: ->
    # Pass 1: Discovery
    @discoverVariables(@root)

    # Pass 2: Declaration planning
    @planDeclarations()

    @variables

  discoverVariables: (node, scope = null) ->
    # Use Solar directives to traverse AST
    node.traverseChildren no, (child) =>
      # Track assignments
      if child instanceof Assign
        varNode = child.variable.unwrapAll()
        if varNode instanceof IdentifierLiteral
          varName = varNode.value
          @variables[varName] ?= {assignments: [], references: [], scopes: []}
          @variables[varName].assignments.push {
            node: child
            scope: scope
            isInTry: @isInTryBlock(child)
            isInLoop: @isInLoop(child)
          }

      # Track references
      if child instanceof IdentifierLiteral and not (child.parent instanceof Assign and child.parent.variable is child)
        varName = child.value
        @variables[varName] ?= {assignments: [], references: [], scopes: []}
        @variables[varName].references.push {
          node: child
          scope: scope
        }

      # Recurse
      @discoverVariables(child, scope)
      yes  # Continue traversal

  planDeclarations: ->
    for varName, data of @variables
      # Determine const vs let
      data.declarationType = if data.assignments.length <= 1 then 'const' else 'let'

      # Determine declaration location
      data.declarationScope = @findOptimalScope(data)

      # Mark for promotion if needed
      data.needsPromotion = @needsPromotion(data)

  findOptimalScope: (data) ->
    # Find the common ancestor scope of all uses
    # This ensures the variable is available everywhere it's needed
    commonScope = null
    for assignment in data.assignments.concat(data.references)
      commonScope = @findCommonAncestor(commonScope, assignment.scope)
    commonScope

  needsPromotion: (data) ->
    # Check if variable crosses try/catch boundaries
    hasAssignmentInTry = data.assignments.some (a) -> a.isInTry
    hasReferenceOutsideTry = data.references.some (r) -> not r.isInTry
    hasAssignmentInTry and hasReferenceOutsideTry
```

## Integration Points

### 1. Scope Class Enhancement
```coffeescript
class Scope
  constructor: ->
    @solarAnalysis = null  # Will hold analysis results

  performSolarAnalysis: (root) ->
    analyzer = new SolarScopeAnalyzer(root)
    @solarAnalysis = analyzer.analyze()
```

### 2. Block Compilation
```coffeescript
compileWithDeclarations: (o) ->
  # Run Solar analysis if not done
  if not o.scope.solarAnalysis
    o.scope.performSolarAnalysis(@)

  # Use analysis to generate optimal declarations
  analysis = o.scope.solarAnalysis
  declarations = @generateDeclarations(analysis)
  # ... rest of compilation
```

### 3. Assign Compilation
```coffeescript
compileNode: (o) ->
  # Check Solar analysis for this variable
  if o.scope.solarAnalysis?[varName]
    analysis = o.scope.solarAnalysis[varName]
    if analysis.needsPromotion
      # Skip inline declaration
      needsDeclaration = false
    else
      declarationKeyword = analysis.declarationType
```

## Benefits

1. **Comprehensive**: Analyzes entire AST before making decisions
2. **Optimal**: Places declarations at the minimal required scope
3. **Correct**: Handles all edge cases (try/catch, loops, conditionals)
4. **Extensible**: Easy to add new analysis rules
5. **Solar-Powered**: Leverages Solar directives for clean AST traversal

## Testing

Test cases to verify:
- Try/catch variable promotion
- Loop variable scoping
- Conditional declarations
- Nested function scoping
- Destructuring assignments
- Chained assignments
