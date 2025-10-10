# The Road to CoffeeScript 3.0.0: A Complete Implementation Guide

## Table of Contents
1. [Overview](#overview)
2. [Understanding Solar Directives](#understanding-solar-directives)
3. [Architecture Overview](#architecture-overview)
4. [Phase 1: Creating v28 - The Lean Foundation](#phase-1-creating-v28)
5. [Phase 2: Dual Compilation Modes](#phase-2-dual-compilation-modes)
6. [Phase 3: Creating v30 - CoffeeScript 3.0.0](#phase-3-creating-v30)
7. [Required Transformations](#required-transformations)
8. [Implementation Priority Order](#implementation-priority-order)
9. [Implementation Steps](#implementation-steps)
10. [Appendix: Concrete Implementation Examples](#appendix-concrete-implementation-examples)

## Overview

This document provides a complete guide to transform CoffeeScript 2.7.0 into CoffeeScript 3.0.0 - a modern, ES6-native version of CoffeeScript that both compiles to and is written in ES6 JavaScript.

### Key Goals
1. **Simplify**: Remove unnecessary complexity (JSX, literate coffee)
2. **Modernize**: Use Solar directives for declarative transformations
3. **ES6-Native**: Generate clean ES6 JavaScript output
4. **Self-Hosting**: CoffeeScript 3.0.0 should compile itself

### Directory Structure
```
coffee/
├── v27/          # Original CoffeeScript 2.7.0 source
├── v28/          # Lean intermediate version with dual compilation
│   ├── src/
│   │   ├── nodes5.coffee   # CommonJS/ES5 compiler
│   │   ├── nodes6.coffee   # ES6 compiler
│   │   ├── grammar.coffee  # Solar-based grammar
│   │   └── ...
│   └── lib/
└── v30/          # CoffeeScript 3.0.0 (pure ES6)
    ├── src/      # ES6-based CoffeeScript source
    └── lib/      # Compiled ES6 JavaScript
```

## Understanding Solar Directives

### What Are Solar Directives?

Solar directives are a declarative, data-driven approach to defining grammar rules and AST transformations. Unlike traditional parser generators like Jison that use imperative code, Solar uses pure data structures to describe transformations.

### Traditional Jison Approach (OLD)
```coffee
# Imperative - you write the transformation code
Assignment: [
  ['Assignable = Expression', -> new Assign $1, $3]
  ['Assignable = INDENT Expression OUTDENT', -> new Assign $1, $4]
]
```

### Solar Directive Approach (NEW)
```coffee
# Declarative - you describe the transformation
Assign: [
  o 'Assignable = Expression',               $ast: '@', variable: 1, value: 3
  o 'Assignable = TERMINATOR Expression',    $ast: '@', variable: 1, value: 4
  o 'Assignable = INDENT Expression OUTDENT', $ast: '@', variable: 1, value: 4
]
```

### Solar Directive Properties

#### `$ast` Property
- `$ast: '@'` - Create an AST node using the rule name (e.g., rule "Assign" creates class Assign)
- `$ast: 'ClassName'` - Explicitly specify the AST node class to create
- `$ast: null` - Don't create an AST node, just return the value

#### Numbered Properties
Numbers refer to positions in the grammar pattern (1-indexed):
```coffee
o 'IMPORT String WITH Obj', $ast: '@', source: 2, assertions: 4
#          ^1    ^2   ^3 ^4
```

#### Special Operations
```coffee
# Operators
$op: 'Add'  # Create an operator node

# Lists
$list: 1    # Convert to list

# Conditional properties
optional: yes
generated: yes
```

### Data Transformations with Solar

Solar performs transformations in multiple stages:

#### Stage 1: Pattern Matching
Solar matches input tokens against grammar patterns, building a parse tree.

#### Stage 2: Data Transformation
Before creating AST nodes, Solar can transform the data:
```coffee
# Example: Transform import paths
ImportDeclaration: [
  o 'IMPORT String',
    $ast: '@'
    source: 2
    $transform: (data) ->
      # Add .js extension if missing
      data.source.value += '.js' unless data.source.value.match /\.\w+$/
      data
]
```

#### Stage 3: AST Generation
Solar uses the transformed data to create AST nodes with all necessary metadata.

#### Stage 4: Two-Pass Compilation
With Solar, we can easily implement two-pass compilation:
```coffee
# Pass 1: Analyze - collect all variable declarations
$analyze: (node, context) ->
  if node.$ast is 'Assign'
    context.variables.push node.variable

# Pass 2: Generate - output with proper declarations
$generate: (node, context) ->
  if context.needsDeclaration(node.variable)
    output = "let #{node.variable}; "
  output += node.compile()
```

## Architecture Overview

### Three-Stage Evolution

1. **v27 → v28**: Strip and modernize
   - Remove JSX, literate coffee, unnecessary features
   - Replace Jison with Solar directives
   - Create dual compilation system

2. **v28 Development**: Dual compilation modes
   - `nodes5.coffee`: Traditional CommonJS/ES5 output
   - `nodes6.coffee`: Modern ES6 output
   - Switch with `ES6=1` environment variable

3. **v28 → v30**: Pure ES6 CoffeeScript
   - Compile with `ES6=1 v28/bin/coffee`
   - Output clean ES6 modules
   - Self-hosting capability

## Phase 1: Creating v28 - The Lean Foundation

### Step 1.1: Copy and Strip

Starting from v27 (CoffeeScript 2.7.0), remove:

#### Features to Remove
1. **JSX Support**
   - Remove from lexer: JSX token patterns
   - Remove from grammar: JSX rules
   - Remove from nodes: JSX compilation

2. **Literate CoffeeScript**
   - Remove support for `.litcoffee`
   - Remove support for `.coffee.md`
   - Remove markdown processing from lexer

3. **Unnecessary Features**
   - Source map generation (temporarily, re-add later if needed)
   - REPL customizations (keep basic REPL)
   - Complex error reporting (keep simple errors)

#### Files to Modify
```
src/lexer.coffee     # Remove JSX/literate tokens
src/grammar.coffee   # Remove JSX/literate rules
src/nodes.coffee     # Remove JSX/literate compilation
src/coffeescript.coffee # Simplify file detection
```

### Step 1.2: Convert to Solar

Replace Jison grammar with Solar directives:

```coffee
# Old Jison (grammar.coffee)
grammar =
  Root: [
    ['', -> new Root]
    ['Body', -> new Root $1]
  ]

# New Solar (grammar.coffee)
grammar =
  Root: [
    o '',      $ast: 'Root'
    o 'Body',  $ast: 'Root', body: 1
  ]
```

### Step 1.3: Implement Solar Backend

Create `backend.coffee` to process Solar directives:
```coffee
class SolarBackend
  constructor: (@ast) ->

  process: (rule, match, directive) ->
    return null unless directive.$ast

    className = if directive.$ast is '@' then rule else directive.$ast
    nodeClass = @ast[className]

    # Collect constructor arguments
    args = []
    for key, position of directive when key not in ['$ast', '$transform']
      args.push @transform match[position - 1]

    # Create node
    new nodeClass args...
```

## Phase 2: Dual Compilation Modes

### Creating nodes5.coffee (ES5/CommonJS Mode)

This is essentially the cleaned-up nodes.coffee from v28, generating traditional JavaScript:

```coffee
class Assign extends Base
  compile: (o) ->
    # Traditional var hoisting
    o.scope.find @variable
    "var #{@variable} = #{@value.compile(o)}"
```

### Creating nodes6.coffee (ES6 Mode)

Enhanced version with ES6 output:

```coffee
class Assign extends Base
  compile: (o) ->
    # Two-pass compilation
    if o.phase is 'analyze'
      o.tracker.addVariable @variable, @
    else
      declaration = o.tracker.getDeclaration @variable
      "#{declaration} #{@variable} = #{@value.compile(o)}"
```

### Build System

```bash
# Compile with ES5 mode (default)
v28/bin/coffee -c src/file.coffee

# Compile with ES6 mode
ES6=1 v28/bin/coffee -c src/file.coffee
```

Implement in `coffeescript.coffee`:
```coffee
compile: (code, options) ->
  ast = parse code
  nodes = if process.env.ES6
    require './nodes6'
  else
    require './nodes5'
  nodes.compile ast, options
```

## Phase 3: Creating v30 - CoffeeScript 3.0.0

### Step 3.1: Initialize v30

```bash
# Create directory structure
mkdir -p v30/src v30/lib/coffeescript

# Copy v28 source as starting point
cp -r v28/src/* v30/src/

# Remove nodes5.coffee (ES6 only)
rm v30/src/nodes5.coffee
mv v30/src/nodes6.coffee v30/src/nodes.coffee
```

### Step 3.2: Compile with ES6 Mode

```bash
# Use v28 in ES6 mode to compile v30
cd v28
ES6=1 ./bin/coffee -c -o ../v30/lib/coffeescript ../v30/src/*.coffee
```

### Step 3.3: Convert to ES6 Modules

Update all v30 source files:
```coffee
# Old (CommonJS)
fs = require 'fs'
exports.compile = ->

# New (ES6)
import fs from 'fs'
export compile = ->
export default CoffeeScript
```

## Required Transformations

### 1. Variable Declaration & Scoping

#### Problem
ES6 has block scoping, CoffeeScript assumes function scoping.

#### Solution
```coffee
# Solar analyzer pass
$analyze:
  Assign: (node, scope) ->
    scope.addVariable node.variable,
      firstAssignment: not scope.has(node.variable)
      reassigned: scope.has(node.variable)

# Solar generator pass
$generate:
  Scope: (node, tracker) ->
    for var in tracker.variables
      if var.reassigned
        output += "let #{var.name}; "
      else
        output += "const #{var.name}; "
```

### 2. Let vs Const Analysis

#### Rules
```coffee
determineDeclaration: (variable, tracker) ->
  return 'const' if variable.isFunction or variable.isClass
  return 'const' if variable.name.match /^[A-Z_]+$/  # SCREAMING_SNAKE
  return 'let' if tracker.isReassigned(variable)
  return 'let' if variable.inLoop
  return 'const'
```

### 3. Module System Transformation

#### Import/Export Detection
```coffee
ModuleTransform:
  # CommonJS → ES6
  'require("module")' -> 'import module from "module"'
  'require("./file")' -> 'import file from "./file.js"'
  'module.exports =' -> 'export default'
  'exports.name =' -> 'export const name ='

  # JSON imports
  'require("data.json")' -> 'import data from "./data.json" with { type: "json" }'
```

### 4. ES5 → ES6 Pattern Replacement

#### Array Methods
```coffee
# indexOf → includes
'array.indexOf(item) >= 0' -> 'array.includes(item)'
'array.indexOf(item) < 0' -> '!array.includes(item)'

# String interpolation → Template literals
'"Hello " + name + "!"' -> '`Hello ${name}!`'
```

### 5. Class Transformation

```coffee
# CoffeeScript class
class Animal
  constructor: (@name) ->
  speak: -> "#{@name} makes a sound"

# ES6 output
class Animal {
  constructor(name) {
    this.name = name;
  }
  speak() {
    return `${this.name} makes a sound`;
  }
}
```

### 6. Async/Await & Generators

```coffee
# Detect and properly output
AsyncTransform:
  'await' -> 'await'
  'yield' -> 'yield'
  'yield from' -> 'yield*'

  # Function detection
  hasAwait: -> markAsAsync: yes
  hasYield: -> markAsGenerator: yes
```

### 7. Helper Function Management

```coffee
# Instead of inline helpers
HelperRegistry:
  indexOf: 'const indexOf = [].indexOf'
  slice: 'const slice = [].slice'

  # Use native when possible
  shouldUseNative: (helper) ->
    return 'includes()' if helper is 'indexOf' and ES6
```

### 8. Comprehension Transformation

```coffee
# Complex comprehensions keep IIFE
'(x * 2 for x in list when x > 0)' ->
  '(function() {
    const results = [];
    for (let x of list) {
      if (x > 0) results.push(x * 2);
    }
    return results;
  })()'

# Simple ones use native methods
'(x * 2 for x in list)' -> 'list.map(x => x * 2)'
```

### 9. Conditional Compilation

```coffee
# Postfix conditionals
'return x if y' -> 'if (y) return x'

# Conditional expressions
'a = if b then c else d' -> 'const a = b ? c : d'
```

### 10. Operator Transformations

```coffee
OperatorMap:
  '**': (a, b) -> "#{a} ** #{b}"        # Exponentiation
  '//': (a, b) -> "Math.floor(#{a} / #{b})"  # Integer division
  '%%': (a, b) -> "((#{a} % #{b}) + #{b}) % #{b}"  # Modulo
  '?': (a) -> "#{a} != null"           # Existence
  '?.': (a, b) -> "#{a}?.#{b}"         # Optional chaining
  '?': (a, b) -> "#{a} ?? #{b}"        # Nullish coalescing
```

### 11. Temporary Variable Management

```coffee
# Track all compiler-generated variables
TempVarTracker:
  generate: (name) ->
    var = @scope.freeVariable(name)
    @track(var, @currentScope)
    var

  declare: ->
    for scope, vars of @tempVars
      scope.addDeclaration "let #{vars.join(', ')}"
```

### 12. IIFE Detection and Elimination

```coffee
IIFEOptimizer:
  isNecessary: (node) ->
    return yes if node.isComplexComprehension
    return yes if node.isDoExpression
    return yes if node.needsScope
    return no

  unwrap: (node) ->
    node.body if not @isNecessary(node)
```

## Implementation Priority Order

### Critical Insight: Foundation Before Features

A common mistake is to start with the most visible problems (like variable declaration errors). However, based on actual implementation experience, the correct order follows a **dependency-driven approach**:

### The Correct Implementation Order

#### 1. **Solar Backend (FOUNDATION - Do First!)**
- **Why First**: Core infrastructure that everything else depends on
- **What**: grammar.coffee, backend.coffee, parser generation
- **Reality Check**: You cannot implement any transformations without Solar working
- **Key Files**:
  - `grammar.coffee` - Solar directive definitions
  - `backend.coffee` - AST transformation engine

#### 2. **Two-Pass Compilation Architecture (STRATEGY - Do Second)**
- **Why Second**: The fundamental architectural pattern that enables correct ES6
- **What**: Scan entire AST first, then generate code with proper declarations
- **Reality Check**: This is THE solution to the variable declaration problem
- **Key Concept**: Must be built into compiler architecture from the start

#### 3. **Variable Declaration Logic (IMPLEMENTATION - Do Third)**
- **Why Third**: With infrastructure and architecture in place, you can now implement
- **What**: let/const decisions, scope tracking, declaration hoisting
- **Reality Check**: Impossible to get right without two-pass approach
- **Complexity**: Yes, it's the most complex, but it DEPENDS on #1 and #2

#### 4. **Test Suite (CONTINUOUS - Do Alongside!)**
- **Why Continuous**: Develop WITH each feature, not after
- **What**: Start simple, add complex cases progressively
- **Reality Check**: The lexer is your ultimate test - it has every problem pattern
- **Strategy**: Every fix reveals new issues - continuous testing is essential

#### 5. **Module Transformation (COMPLETION - Do Last)**
- **Why Last**: Important for self-hosting but not critical for basic functionality
- **What**: Convert require/exports to import/export
- **Reality Check**: You can use hybrid approach initially
- **Note**: Can get pretty far without fully solving this

### Why This Order Matters

Think of it like building a house:
- **Solar Backend** = The tools and materials
- **Two-Pass Architecture** = The blueprint
- **Variable Declaration** = The actual construction
- **Testing** = Quality control at each step
- **Module Transformation** = The finishing touches

**You cannot start construction without tools and a blueprint!**

### Common Pitfall to Avoid

Don't start with "Variable Declaration Logic" just because it's the most visible problem. It's actually impossible to solve properly without:
1. Solar infrastructure to transform the AST
2. Two-pass architecture to collect information before generating code

## Implementation Steps

### Step 1: Set Up v28 Directory
```bash
# Create clean v28
mkdir -p v28/src v28/lib
cp -r v27/src/* v28/src/
cp v27/package.json v28/
```

### Step 2: Strip Unnecessary Features
```bash
# Remove JSX and literate coffee
cd v28/src
# Edit lexer.coffee - remove JSX tokens, literate patterns
# Edit grammar.coffee - remove JSX rules
# Edit nodes.coffee - remove JSX compilation methods
```

### Step 3: Implement Solar System
```coffee
# v28/src/grammar.coffee
SolarGrammar = require './solar-grammar'
grammar = new SolarGrammar()

# Define rules with Solar directives
grammar.rule 'Root', [
  o '',      $ast: 'Root'
  o 'Body',  $ast: 'Root', body: 1
]
```

### Step 4: Create Dual Compilation
```coffee
# v28/src/nodes5.coffee - ES5 output (copy from cleaned nodes.coffee)
# v28/src/nodes6.coffee - ES6 output (enhanced with transformations)

# v28/src/coffeescript.coffee
compile: (code, options = {}) ->
  nodes = if process.env.ES6
    require './nodes6'
  else
    require './nodes5'
```

### Step 5: Test v28
```bash
# Test ES5 mode
cd v28
./bin/coffee -c test.coffee

# Test ES6 mode
ES6=1 ./bin/coffee -c test.coffee
```

### Step 6: Create v30
```bash
# Set up v30
mkdir -p v30/src v30/lib

# Copy v28 source
cp -r v28/src/* v30/src/

# Remove ES5 compiler
rm v30/src/nodes5.coffee
mv v30/src/nodes6.coffee v30/src/nodes.coffee

# Update to ES6 modules
# Edit all files: require → import, exports → export
```

### Step 7: Compile v30
```bash
# Use v28 to compile v30
cd v28
ES6=1 ./bin/coffee -c -o ../v30/lib/coffeescript ../v30/src/*.coffee
```

### Step 8: Test v30
```bash
# v30 should now be able to compile itself
cd v30
./bin/coffee -c test.coffee  # Should output ES6
```

### Step 9: Bootstrap
```bash
# v30 compiles itself
cd v30
./bin/coffee -c -o lib/coffeescript src/*.coffee
```

## Success Criteria

1. **v28 Works**: Can compile CoffeeScript to both ES5 and ES6
2. **v30 Compiles**: v28 can compile v30 source
3. **v30 Runs**: v30 can execute and compile CoffeeScript
4. **v30 Self-Hosts**: v30 can compile itself
5. **ES6 Output**: All output is clean, modern ES6

## Testing Strategy

### Unit Tests
```coffee
# Test each transformation
describe 'ES6 Transformations', ->
  it 'uses const for functions', ->
    input = 'f = -> 42'
    output = compile input, es6: yes
    expect(output).toContain 'const f ='
```

### Integration Tests
```coffee
# Test complete programs
describe 'Full Programs', ->
  it 'compiles complex class', ->
    # Test class with async, static, private fields
```

### Bootstrap Test
```bash
# Ultimate test: v30 compiles itself
cd v30
./bin/coffee -c -o test-lib src/*.coffee
diff -r lib test-lib  # Should be identical
```

## Troubleshooting Guide

### Common Issues

1. **Variable not declared**
   - Check two-pass analysis is collecting all assignments
   - Verify scope tracking is correct

2. **Import/Export errors**
   - Ensure all require/exports are transformed
   - Check JSON import assertions

3. **IIFE still present**
   - Verify IIFE optimizer is running
   - Check if IIFE is actually necessary

4. **Helper functions missing**
   - Ensure helper registry is initialized
   - Check helpers are declared at module level

## Conclusion

This transformation will create a modern, maintainable CoffeeScript 3.0.0 that:
- Generates clean ES6 JavaScript
- Uses Solar directives for clear, declarative transformations
- Can compile itself (self-hosting)
- Removes unnecessary complexity
- Is ready for future enhancements

The key is the systematic approach: strip down to essentials (v28), add ES6 generation capability, then create the pure ES6 version (v30). Solar directives make this transformation manageable and maintainable.

## Appendix: Concrete Implementation Examples

This appendix provides concrete code examples and implementation patterns discovered during development. These examples should be used as reference when implementing the transformations described above.

### A. Critical ES6 Variable Declaration Patterns

One of the trickiest aspects of compiling CoffeeScript to ES6 is handling inline assignments properly. Here are the patterns that MUST be implemented:

#### Pattern 1: Assignment in Conditionals

**CoffeeScript Input:**
```coffee
return 0 unless match = IDENTIFIER.exec @chunk
```

**INCORRECT ES6 (causes ReferenceError):**
```javascript
if (!(match = IDENTIFIER.exec(this.chunk))) {
  return 0;
}
```

**CORRECT ES6:**
```javascript
let match;
if (!(match = IDENTIFIER.exec(this.chunk))) {
  return 0;
}
```

**Why:** JavaScript doesn't allow declarations inside conditional expressions. You **must** declare the variable before the conditional.

#### Pattern 2: Destructuring with Fallback

**CoffeeScript Input:**
```coffee
[quote] = STRING_START.exec(@chunk) || []
```

**Option A - Inline Declaration (when variable won't be reassigned):**
```javascript
const [quote] = STRING_START.exec(this.chunk) || [];
```

**Option B - Separate Declaration (when variable might be reassigned):**
```javascript
let quote;
[quote] = STRING_START.exec(this.chunk) || [];
```

#### Pattern 3: While Loop Assignments

**CoffeeScript Input:**
```coffee
while match = REGEX.exec str
  process match
```

**CORRECT ES6:**
```javascript
let match;
while (match = REGEX.exec(str)) {
  process(match);
}
```

#### Pattern 4: Switch/When Assignments

**CoffeeScript Input:**
```coffee
switch
  when match = REGEX.exec @chunk
    handleMatch match
```

**CORRECT ES6:**
```javascript
let match;
switch (false) {
  case !(match = REGEX.exec(this.chunk)):
    handleMatch(match);
}
```

### B. Working Solar Grammar Examples

These are actual Solar directive patterns that work:

```coffee
# grammar.coffee
Assign: [
  o 'Assignable = Expression',               $ast: '@', variable: 1, value: 3
  o 'Assignable = TERMINATOR Expression',    $ast: '@', variable: 1, value: 4
  o 'Assignable = INDENT Expression OUTDENT', $ast: '@', variable: 1, value: 4
]

ImportDeclaration: [
  o 'IMPORT String',                          $ast: '@', source: 2
  o 'IMPORT String WITH Obj',                 $ast: '@', source: 2, assertions: 4
  o 'IMPORT ImportClause FROM String',        $ast: '@', clause: 2, source: 4
  o 'IMPORT ImportClause FROM String WITH Obj', $ast: '@', clause: 2, source: 4, assertions: 6
]

Class: [
  o 'CLASS',                                  $ast: '@'
  o 'CLASS Block',                             $ast: '@', body: 2
  o 'CLASS EXTENDS Expression',                $ast: '@', parent: 3
  o 'CLASS EXTENDS Expression Block',          $ast: '@', parent: 3, body: 4
  o 'CLASS SimpleAssignable',                  $ast: '@', variable: 2
  o 'CLASS SimpleAssignable Block',            $ast: '@', variable: 2, body: 3
  o 'CLASS SimpleAssignable EXTENDS Expression', $ast: '@', variable: 2, parent: 4
  o 'CLASS SimpleAssignable EXTENDS Expression Block', $ast: '@', variable: 2, parent: 4, body: 5
]
```

### C. Scope Management Implementation

Here's the critical scope tracking code that must be implemented:

```coffee
# In nodes6.coffee - Enhanced Scope class for ES6
class Scope
  constructor: (@parent, @expressions, @method, @referencedVars) ->
    @variables = [{name: 'arguments', type: 'arguments'}]
    @positions = {}
    @utilities = {} unless @parent
    @root = @parent?.root ? this

    # ES6 additions
    @generatedVars = []  # Track compiler-generated variables
    @children = []        # Track child scopes
    if @parent
      @parent.children.push this

  # Track free variables for ES6 declaration
  freeVariable: (name, options={}) ->
    index = 0
    loop
      temp = @temporary name, index, options.single
      break unless @check(temp) or temp in @root.referencedVars
      index++
    @add temp, 'var', yes if options.reserve ? true

    # ES6: Track generated variables
    if process.env.ES6
      @generatedVars.push temp unless temp in @generatedVars

    temp
```

### D. Two-Pass Compilation Implementation

The heart of ES6 compilation is the two-pass approach:

```coffee
# In Block class - Collect ALL assignments before compilation
collectAllAssignments: (o) ->
  return [] unless process.env.ES6
  assignments = []

  collectAssignments = (node, inCondition = no) =>
    return unless node

    # Handle Return statements with assignments
    if node instanceof Return and node.expression
      collectAssignments node.expression, inCondition

    # Handle conditionals
    else if node instanceof If or node instanceof While or node instanceof Switch
      # Check condition for assignments - THIS IS CRITICAL
      if node.condition
        collectAssignments node.condition, yes
      if node.processedCondition?()
        collectAssignments node.processedCondition(), yes
      # Then check bodies
      collectAssignments node.body, no if node.body
      collectAssignments node.elseBody, no if node.elseBody

    # Handle assignments
    else if node instanceof Assign and not node.context
      varNode = node.variable.unwrapAll?() ? node.variable
      if varNode instanceof IdentifierLiteral
        varName = varNode.value
        if not o.scope.check(varName)
          assignments.push {name: varName, inCondition}

      # Handle destructuring
      else if node.variable.isArray?() or node.variable.isObject?()
        collectDestructuringVars node.variable, assignments, o

    # Recursive traversal
    if node.traverseChildren
      node.traverseChildren no, (child) ->
        collectAssignments child, inCondition
        yes

  # Process all expressions
  for expr in @expressions
    collectAssignments expr

  assignments

# Use collected assignments to generate declarations
compileWithDeclarations: (o) ->
  fragments = []

  # ES6: Declare all variables upfront
  if process.env.ES6
    allAssignments = @collectAllAssignments(o)
    if allAssignments.length > 0
      declaredVars = []
      for assignment in allAssignments
        declaredVars.push assignment.name unless assignment.name in declaredVars

      # Add to scope
      for varName in declaredVars
        o.scope.add varName, 'var'

      # Generate declaration
      if declaredVars.length > 0
        fragments.push @makeCode "#{@tab}let #{declaredVars.join(', ')};\n"

  # Continue with normal compilation...
```

### E. Specific Problem Fixes

#### Fix 1: Results Variable in Comprehensions

**Problem:** `results = []` generated without declaration

**Solution in For.compileNode:**
```coffee
if @returns
  resultPart = "#{@tab}const #{rvar} = [];\n"  # Changed to include const
  returnResult = "\n#{@tab}return #{rvar};"
  body.makeReturn rvar
```

#### Fix 2: Try/Catch Variable Promotion

**Problem:** Variables in try block not accessible in catch

**Solution:**
```coffee
class Try
  analyzeAndPromoteVariables: (o) ->
    return [] unless @catch or @ensure
    promotedVars = []

    # Find variables assigned in try
    tryVars = {}
    @attempt.traverseChildren no, (node) ->
      if node instanceof Assign
        varNode = node.variable.unwrapAll?()
        if varNode instanceof IdentifierLiteral
          tryVars[varNode.value] = yes
      yes

    # Check if used in catch/ensure
    for varName of tryVars
      continue if o.scope.check(varName)

      isUsedOutside = no
      if @catch
        @catch.traverseChildren no, (n) ->
          if n instanceof IdentifierLiteral and n.value is varName
            isUsedOutside = yes
            return no
          yes

      if isUsedOutside
        promotedVars.push varName

    promotedVars

  compileNode: (o) ->
    promotedVars = @analyzeAndPromoteVariables(o)
    declarations = []

    for varName in promotedVars
      declarations.push @makeCode "#{@tab}let #{varName};\n"
      o.scope.add varName, 'var'

    # Rest of compilation with declarations prepended...
```

#### Fix 3: Chained Assignments

**Problem:** `tp = as = ""` generates invalid ES6

**Solution:**
```coffee
# In Assign.compileNode
if isChainedAssignment and not isInsideExpression
  # Collect all variables in chain
  chainedVars = []
  if @variable.unwrapAll() instanceof IdentifierLiteral
    firstVar = @variable.unwrapAll().value
    chainedVars.push firstVar if not o.scope.check(firstVar)

  current = @value
  while current instanceof Assign and not current.context
    if current.variable.unwrapAll() instanceof IdentifierLiteral
      innerVar = current.variable.unwrapAll().value
      chainedVars.push innerVar if not o.scope.check(innerVar)
    current = current.value

  # Generate: let tp, as; tp = as = "";
  if chainedVars.length > 0
    declStatement = @makeCode "let #{chainedVars.join(', ')}; "
    answer.unshift declStatement
```

#### Fix 4: JSON Import Assertions

**Problem:** JSON imports need `with { type: 'json' }`

**Solution in ImportDeclaration.compileNode:**
```coffee
if process.env.ES6 and @source.value.match(/\.json['"]$/) and not @assertions?
  code.push @makeCode " with { type: 'json' }"
else if @assertions?
  code.push @makeCode ' with '  # Changed from 'assert'
  code.push @assertions.compileToFragments(o)...
```

#### Fix 5: Helper Functions

**Problem:** Multiple `indexOf1`, `indexOf2` helpers generated

**Solution:**
```coffee
# Use native methods in ES6
if process.env.ES6
  fragments = @array.compileToFragments(o, LEVEL_LIST)
  fragments.push @makeCode(".includes(")
  fragments.push ref...
  fragments.push @makeCode(")")
  if @negated
    fragments.unshift @makeCode("!")
else
  # Fall back to indexOf for ES5
  utility('indexOf', o)
```

### F. Conditional Variable Hoisting

For if/else blocks where variables are used across branches:

```coffee
class If
  analyzeVariableHoisting: (o) ->
    return [] unless process.env.ES6

    # Collect variables from ALL branches
    varsByBranch = []

    # Main body
    bodyVars = {}
    @body?.traverseChildren no, (node) ->
      if node instanceof Assign and not node.context
        varNode = node.variable.unwrapAll?()
        if varNode instanceof IdentifierLiteral
          bodyVars[varNode.value] = yes
      yes
    varsByBranch.push bodyVars

    # Walk else-if chain
    current = @elseBody
    while current
      branchVars = {}
      if current.expressions
        unwrapped = current.unwrap()
        if unwrapped instanceof If
          # Collect from else-if body
          unwrapped.body?.traverseChildren no, (node) ->
            if node instanceof Assign and not node.context
              varNode = node.variable.unwrapAll?()
              if varNode instanceof IdentifierLiteral
                branchVars[varNode.value] = yes
            yes
          varsByBranch.push branchVars
          current = unwrapped.elseBody
        else
          # Regular else block
          current.traverseChildren no, (node) ->
            if node instanceof Assign and not node.context
              varNode = node.variable.unwrapAll?()
              if varNode instanceof IdentifierLiteral
                branchVars[varNode.value] = yes
            yes
          varsByBranch.push branchVars
          current = null
      else
        current = null

    # Find variables needing hoisting
    allVars = {}
    for branch in varsByBranch
      for varName of branch
        allVars[varName] = yes

    hoistedVars = []
    for varName of allVars
      if not o.scope.check(varName)
        hoistedVars.push varName

    hoistedVars

  compileStatement: (o) ->
    # Only hoist if not a child in else-if chain
    declarations = []
    if not o.chainChild
      hoistedVars = @analyzeVariableHoisting(o)

      if hoistedVars.length > 0
        for varName in hoistedVars
          o.scope.add varName, 'var'

        declarations.push @makeCode "#{@tab}let #{hoistedVars.join(', ')};\n"
        o = merge o, {hoistedIfVars: hoistedVars}

    # Rest of normal compilation...
```

### G. Key Implementation Notes

1. **Always Check Scope First**: Before declaring any variable, check if it's already in scope with `o.scope.check(varName)`

2. **Track Context**: Pass context through compilation (promotedTryVars, hoistedIfVars, etc.) to prevent duplicate declarations

3. **Handle Generated Variables**: The compiler generates `ref`, `ref1`, etc. These MUST be tracked and declared

4. **Use Two Passes**:
   - Pass 1: Walk entire AST, collect ALL assignments
   - Pass 2: Generate code with proper declarations

5. **Test Patterns**: The lexer is the ultimate test - it has ALL the problem patterns

### H. Testing Your Implementation

Test these specific patterns that commonly fail:

```coffee
# Test 1: Conditional assignment
test1 = ->
  return 0 unless match = /test/.exec input
  match[1]

# Test 2: Destructuring with fallback
test2 = ->
  [a, b] = getArray() || []
  console.log a, b

# Test 3: While with assignment
test3 = ->
  while item = queue.shift()
    process item

# Test 4: Try/catch with shared variable
test4 = ->
  try
    result = doSomething()
  catch err
    console.log result  # Must be accessible

# Test 5: Chained assignment
test5 = ->
  a = b = c = 0
  console.log a, b, c

# Test 6: Complex comprehension
test6 = ->
  results = (x * 2 for x in list when x > 0)
  results
```

### I. Common Pitfalls to Avoid

1. **Don't Add Declarations to Source**: Never add `let match = null` to CoffeeScript source - the compiler must handle this

2. **Don't Forget Destructuring**: Destructuring patterns need special handling for variable collection

3. **Watch for 'in' Operator**: CoffeeScript's `in` compiles to indexOf/includes, generating temp variables

4. **Handle All Assignment Contexts**: Assignments can appear in conditions, loops, returns, switch cases, etc.

5. **Preserve Semantics**: Some patterns (complex comprehensions) need IIFEs to preserve CoffeeScript semantics

### J. Build Commands Reference

```bash
# Build v28 from v27
cd v27
npm install
./bin/cake build  # Creates initial lib files

# Create v28
cp -r v27 v28
cd v28
# Strip JSX, literate, implement Solar

# Test v28 ES5 mode
./bin/coffee -c test.coffee

# Test v28 ES6 mode
ES6=1 ./bin/coffee -c test.coffee

# Build v30 using v28
cd v28
ES6=1 ./bin/coffee -c -o ../v30/lib/coffeescript ../v30/src/*.coffee

# Bootstrap v30
cd v30
./bin/coffee -c -o lib/coffeescript src/*.coffee
```

### K. Debugging Tips

When something doesn't work:

1. **Check Generated JavaScript**: Look at the actual output - is the variable declared?

2. **Add Debug Output**:
   ```coffee
   console.error "DEBUG: Collected vars:", collectedVars
   ```

3. **Test Incrementally**: Start with simple cases, build up to complex

4. **Compare with Working Code**: v28/src/nodes6.coffee has many working examples

5. **Use Markers**: Add comments to generated code to track transformations:
   ```coffee
   @makeCode "/* DECLARATION */ let #{varName};"
   ```

This appendix should provide enough concrete examples and implementation details for another AI to successfully implement CoffeeScript 3.0.0. The key is understanding that every assignment must be tracked and every variable must be declared in ES6.
