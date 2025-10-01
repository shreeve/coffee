# ES5 to ES6 JavaScript Transformation Guide

## Executive Summary

Converting CoffeeScript's output from ES5 to ES6 JavaScript requires fundamental changes to the compilation process. This document summarizes the complete transformation requirements based on analysis of other implementations.

## Core Transformations Required

### 1. Variable Declarations

#### ES5 Pattern (Current)
```javascript
// Hoisted to top of scope
var x, y, counter;
x = 42;
y = "hello";
counter = 0;
counter = counter + 1;
```

#### ES6 Pattern (Target)
```javascript
// Declared at first use
const x = 42;           // Never reassigned
const y = "hello";      // Never reassigned
let counter = 0;        // Will be reassigned
counter = counter + 1;
```

**Implementation Requirements:**
- Track variable reassignments throughout scope
- Determine const vs let at compilation time
- Eliminate hoisting pattern
- Declare variables at first assignment

### 2. Function Syntax

#### ES5 Pattern
```javascript
var double;
double = function(x) {
  return x * 2;
};
```

#### ES6 Pattern
```javascript
const double = (x) => x * 2;
// Or for multi-line:
const process = (data) => {
  console.log("Processing...");
  return data * 2;
};
```

### 3. Module System

#### ES5 Pattern
```javascript
var helpers = require('./helpers');
exports.myFunction = function() {};
module.exports = MyClass;
```

#### ES6 Pattern
```javascript
import * as helpers from './helpers.js';  // Note: .js extension required
export const myFunction = () => {};
export default MyClass;
```

**Critical Details:**
- Imports must be hoisted to absolute top
- Relative imports need `.js` extension for Node.js
- Named exports should use `export const` for functions/values
- Classes can use `export class` directly

### 4. Classes

#### ES5 Pattern
```javascript
var Animal = (function() {
  function Animal(name) {
    this.name = name;
  }
  Animal.prototype.speak = function() {
    return console.log(this.name);
  };
  return Animal;
})();
```

#### ES6 Pattern
```javascript
class Animal {
  constructor(name) {
    this.name = name;
  }
  speak() {
    console.log(this.name);
  }
}
```

### 5. Template Literals

#### ES5 Pattern
```javascript
var message = "Hello " + name + "!";
```

#### ES6 Pattern
```javascript
const message = `Hello ${name}!`;
```

### 6. Destructuring

#### ES5 Pattern
```javascript
var name = person.name, age = person.age;
```

#### ES6 Pattern
```javascript
const {name, age} = person;
```

### 7. Spread Operator

#### ES5 Pattern
```javascript
var combined = [first].concat(middle).concat([last]);
```

#### ES6 Pattern
```javascript
const combined = [first, ...middle, last];
```

## Implementation in CoffeeScript Compiler

### Files That Must Be Modified

#### 1. `nodes.coffee` (Primary - ~6000 lines)
**Critical Changes:**

```coffee
# In Block.compileWithDeclarations
# OLD: Hoisting pattern
if declars or assigns
  fragments.push @makeCode "#{@tab}var "
  # ... declare all variables at top

# NEW: Skip hoisting entirely
if scope.expressions is this
  # ES6: No hoisting - variables declared inline at first use
  if fragments.length and post.length
    fragments.push @makeCode "\n"
```

```coffee
# In Assign.compileNode
# NEW: Add smart const/let analysis
needsDeclaration = false
declarationKeyword = 'let'

if @variable.unwrapAll() instanceof IdentifierLiteral
  varName = @variable.unwrapAll().value

  if not o.scope.check(varName)
    needsDeclaration = true

    if @value instanceof Code or @value instanceof Class
      declarationKeyword = 'const'
    else
      declarationKeyword = if @willBeReassignedInScope(o, varName) then 'let' else 'const'

# Prepend declaration
if needsDeclaration
  answer.unshift @makeCode "#{declarationKeyword} "
```

```coffee
# NEW METHOD: Track reassignments
willBeReassignedInScope: (o, varName) ->
  assignmentCount = 0

  checkNode = (node) =>
    if node instanceof Assign and
       node.variable.unwrapAll().value is varName
      assignmentCount++

  o.scope.expressions.traverseChildren false, checkNode
  assignmentCount > 1
```

#### 2. `scope.litcoffee` (~120 lines)
**For CS29 nodes6.coffee approach:**

```coffee
# Add reassignment tracking
constructor: ->
  @reassignments = {}  # Track variables that are reassigned

markAsReassigned: (name) ->
  @reassignments[name] = true
  @parent?.markAsReassigned name if @parent?

isConstantEligible: (name) ->
  return false if @reassignments[name]
  variable = @variables[@positions[name]]
  return false if variable?.type is 'param'
  true
```

#### 3. Import/Export Handling

**In ImportDeclaration.compileNode:**
```coffee
# Add .js extensions to relative imports
sourceValue = @source.value
if sourceValue.match(/^['"]\.\.?\//)?  # './...' or '../...'
  unquoted = sourceValue.slice(1, -1)
  unless unquoted.match(/\.\w+$/)?  # No extension
    quoteMark = sourceValue[0]
    sourceValue = "#{quoteMark}#{unquoted}.js#{quoteMark}"
```

**In ExportDeclaration.compileNode:**
```coffee
# Use 'export const' for named exports
if @clause instanceof Class
  @clause.moduleDeclaration = 'export'
else if @clause instanceof Assign
  code.push @makeCode 'const '
  @clause.moduleDeclaration = 'export'
```

**In Block.compileRoot:**
```coffee
# Hoist imports to top
imports = []
others = []
for exp in @expressions
  if exp instanceof ImportDeclaration
    imports.push exp
  else
    others.push exp

# Compile imports first
if imports.length > 0
  importFragments = []
  for imp in imports
    importFragments.push imp.compileToFragments(o)...
  fragments = importFragments.concat fragments
```

### Optional: Backend System

#### For CS300 Approach - `es6.coffee` or `backend.coffee`
- Processes Solar directives
- Handles AST transformations
- Can inject ES6-specific logic

## The Bootstrap Problem

### The Fundamental Challenge

```
CoffeeScript Source → Compiler → JavaScript Output
     (ES6 ready)    (ES5 based)    (ES5 style)
                          ↓
                    Need ES6 compiler
                          ↓
                    But compiler is ES5!
```

### Solutions Attempted

#### 1. CS29 Approach - Dual Nodes Files
```bash
nodes5.coffee  # ES5 output (for self-compilation)
nodes6.coffee  # ES6 output (for target compilation)

# Scripts to switch:
npm run link5  # Use ES5 nodes
npm run link6  # Use ES6 nodes
```

#### 2. CS300 Approach - Manual Editing
- Compile with regular CoffeeScript
- Manually edit `lib/coffeescript/nodes.js`
- Add ES6 features directly to JavaScript

#### 3. Multi-Stage Build
1. Compile with system CoffeeScript (2.7.0)
2. Use that to compile ES6-aware version
3. Use ES6-aware version for final output

## Implementation Complexity

### Minimal Implementation (2 files)
- `nodes.coffee` - Core compilation changes
- `scope.litcoffee` - Variable tracking

**Limitations:**
- Basic const/let only
- No sophisticated analysis
- May miss edge cases

### Full Implementation (5+ files)
- `nodes.coffee` - Core compilation
- `scope.litcoffee` - Variable tracking
- `coffeescript.coffee` - Module handling
- `lexer.coffee` - Token modifications
- `rewriter.coffee` - Import/export handling
- `helpers.coffee` - Utility functions
- `backend.coffee` or `es6.coffee` - ES6-specific backend

## Critical Decisions

### 1. Hoisting Strategy
**Options:**
- **Remove entirely** (CS300 approach) - Most ES6-like
- **Keep with let** (CS29 nodes6 approach) - Safer but less idiomatic
- **Hybrid** - Hoist some, inline others

### 2. const vs let Determination
**Options:**
- **Conservative** - Use let everywhere (safe but not optimal)
- **Aggressive** - Use const wherever possible (requires full analysis)
- **Heuristic** - const for functions/classes, let for others

### 3. Build Process
**Options:**
- **Manual editing** - Edit JavaScript after compilation
- **Dual compilation** - Maintain ES5 and ES6 versions
- **Self-hosting** - Complex bootstrap process

## Testing Requirements

### Essential Test Cases

```coffee
# 1. Variable declarations
x = 42                    # Should be: const x = 42

# 2. Reassignments
counter = 0               # Should be: let counter = 0
counter++

# 3. Conditional assignments
result = if test         # Should be: let result
  "yes"
else
  "no"

# 4. Functions
double = (x) -> x * 2    # Should be: const double = (x) => x * 2

# 5. Classes
class Animal             # Should be: class Animal { ... }
  constructor: (@name) ->

# 6. Imports/Exports
import {x} from './lib'  # Should add .js extension
export myFunc = ->       # Should be: export const myFunc = () =>
```

## Performance Considerations

### Compilation Time
- Reassignment analysis adds O(n²) complexity in worst case
- Import hoisting requires additional pass
- Overall impact: ~10-20% slower compilation

### Runtime Performance
- ES6 output generally faster in modern engines
- const enables better optimizations
- Arrow functions have less overhead

## Known Issues & Limitations

### 1. Temporal Dead Zone
- Current implementation doesn't respect TDZ
- Variables still conceptually hoisted
- Access before declaration not prevented

### 2. Block Scoping
- CoffeeScript uses function scoping
- True block scoping would require major rewrite
- let/const still function-scoped in practice

### 3. Edge Cases
- Destructuring with defaults
- Complex reassignment patterns
- Dynamic imports
- Circular dependencies

## Recommendations

### For Production Use
1. Start with conservative approach (all let)
2. Add const for obvious cases (functions, classes)
3. Thoroughly test with existing codebase
4. Consider manual post-processing for critical files

### For Development
1. Use CS300 as reference implementation
2. Focus on correctness over optimization
3. Maintain clear separation between ES5/ES6 modes
4. Document all deviations from standard ES6

## Conclusion

Full ES5 to ES6 transformation requires:
- **Minimum**: 2 file modifications (nodes.coffee, scope.litcoffee)
- **Recommended**: 5-7 file modifications for robust support
- **Reality**: Manual intervention often needed
- **Time estimate**: 2-4 weeks for full implementation
- **Complexity**: High due to bootstrap problem

The transformation is technically feasible but requires careful consideration of the bootstrap problem and acceptance of certain limitations due to CoffeeScript's fundamental design assumptions.
