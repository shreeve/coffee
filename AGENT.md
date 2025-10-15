# CoffeeScript ES5 to ES6 Migration Guide

## Goal
Transform CoffeeScript to generate pure ES6 JavaScript output while maintaining backward compatibility through a careful bootstrap process.

## The Three-File Bootstrap Strategy

### File Structure
1. **v28/src/nodes5.coffee** - Generates ES5 (current default, maintains compatibility)
2. **v28/src/nodes.coffee** - Generates ES6 but runs in ES5 environment (the bridge)
3. **v30/src/nodes.coffee** - Generates ES6 and uses ES6 syntax (the future)

### Build Commands
- `npm run build` (v28 dir) - Uses nodes5.coffee for ES5 output
- `npm run build6` (v28 dir) - Uses nodes.coffee to compile v30/src → v30/lib with ES6 output

## Incremental Implementation Plan

### Phase 0: Nullish Coalescing (Simplest Fix - Start Here!)

#### Step 0.1: Replace Existential Operator with Nullish Coalescing
**File**: `nodes.coffee` - `Op.compileExistence` (around line 4764)
```coffee
# The entire fix - replace complex caching logic with native ??
compileExistence: (o, checkOnlyUndefined) ->
  left = @first.compileToFragments o, LEVEL_OP
  right = @second.compileToFragments o, LEVEL_OP
  answer = [].concat left, @makeCode(" ?? "), right
  if o.level <= LEVEL_OP then answer else @wrapInParentheses answer
```

**What this replaces**: ~30 lines of complex code that:
- Created temporary variables (`ref`)
- Cached expressions to avoid double evaluation
- Generated verbose `!= null` checks
- Wrapped everything in conditional expressions

**Examples**:
```coffee
# CoffeeScript input:
x = y ? "default"
func() ? "fallback"
Array::some ? -> false
export value = data ? 42

# ES5 output (OLD - complex):
var ref;
x = (ref = y) != null ? ref : "default";

# ES6 output (NEW - simple):
const x = y ?? "default";
func() ?? "fallback";
Array.prototype.some ?? (() => false);
export const value = data ?? 42;
```

**Why this is perfect to start with**:
- Zero dependencies on other features
- Immediately visible improvement in output
- Native JavaScript operator (no polyfill needed)
- Handles all edge cases automatically
- Actually REMOVES complexity instead of adding it

**Test**:
```coffee
# test_nullish.coffee
a = b ? "default"
result = getUserName() ? "Anonymous"
export helper = Array::find ? -> null
```
Should compile to use `??` throughout

**Commit**: "Replace existential operator with nullish coalescing (??)"

### Phase 1: Module System (Second Easiest, Most Isolated)

#### Step 1.1: Basic Import/Export Syntax
**File**: `nodes.coffee` - `ImportDeclaration`, `ExportDeclaration`
```coffee
# Change: require() → import
# Before: const {x, y} = require('./helpers');
# After:  import {x, y} from './helpers';

# Change: exports → export
# Before: exports.MyClass = MyClass;
# After:  export {MyClass};
```
**Test**: Compile a single file with imports/exports, verify syntax is correct
**Commit**: "Add basic ES6 import/export syntax generation"

#### Step 1.2: Import Path Resolution
**File**: `nodes.coffee` - `ImportDeclaration.compileNode`
```coffee
# Auto-append .js to relative imports without extension
# './helpers' → './helpers.js'
# 'lodash' → 'lodash' (unchanged - npm package)
```
**Test**: Verify local imports get .js, packages don't
**Commit**: "Add .js extension to local imports"

#### Step 1.3: Import Hoisting
**File**: `nodes.coffee` - `Block.compileRoot`
```coffee
# Reorder: All imports to top, maintaining their relative order
# Before: Mixed imports throughout
# After:  All imports at top
```
**Test**: File with mixed imports/code compiles with imports first
**Commit**: "Hoist imports to top of file"

### Phase 2: Arrow Functions (Independent)

#### Step 2.1: Simple Arrow Functions
**File**: `nodes.coffee` - `Code.compileNode`
```coffee
# Non-bound functions without 'this' usage
# Before: function(x) { return x * 2; }
# After:  (x) => x * 2
```
**Test**: Simple functions compile to arrows
**Commit**: "Generate arrow functions for simple cases"

#### Step 2.2: Preserve Traditional Functions
**File**: `nodes.coffee` - `Code.compileNode`
```coffee
# Keep 'function' for: constructors, generators, methods needing 'this'
# Detect via: @bound, @isGenerator, contains 'this' reference
```
**Test**: Class methods still use function syntax
**Commit**: "Preserve function keyword where needed"

### Phase 3: Variable Declarations (More Complex)

#### Step 3.1: Simple const for Never-Reassigned
**File**: `nodes.coffee` - `Block.compileWithDeclarations`
```coffee
# Variables that are assigned once and never reassigned
# Before: var x; x = 5;
# After:  const x = 5;
```
**Test**: Single assignment becomes const
**Commit**: "Use const for never-reassigned variables"

#### Step 3.2: let for Reassigned Variables
**File**: `nodes.coffee` - `Scope` class
```coffee
# Add tracking: markReassigned(name), isReassigned(name)
# Before: var x; x = 5; x = 10;
# After:  let x = 5; x = 10;
```
**Test**: Reassigned variables use let
**Commit**: "Track reassignments and use let"

#### Step 3.3: Inline Declarations
**File**: `nodes.coffee` - `Assign.compileNode`
```coffee
# Declare at first assignment instead of hoisting
# Before: var x, y; x = 5; y = 10;
# After:  const x = 5; const y = 10;
```
**Test**: No hoisted declarations for simple cases
**Commit**: "Inline variable declarations at first use"

### Phase 4: Class Improvements

#### Step 4.1: Class Fields
**File**: `nodes.coffee` - `Class.compileNode`
```coffee
# Use native class fields
# Before: constructor() { this.x = 5; }
# After:  class { x = 5; }
```
**Test**: Instance properties become class fields
**Commit**: "Use native class fields syntax"

#### Step 4.2: Static Methods
**File**: `nodes.coffee` - `Class.compileNode`
```coffee
# Before: MyClass.staticMethod = function() {}
# After:  class MyClass { static staticMethod() {} }
```
**Test**: Static methods use static keyword
**Commit**: "Generate static class methods"

### Phase 5: Template Literals

#### Step 5.1: Basic String Interpolation
**File**: `nodes.coffee` - `StringWithInterpolations.compileNode`
```coffee
# Before: "Hello " + name + "!"
# After:  `Hello ${name}!`
```
**Test**: String interpolation uses template literals
**Commit**: "Use template literals for interpolation"

### Phase 6: Destructuring

#### Step 6.1: Parameter Destructuring
**File**: `nodes.coffee` - `Param.compileNode`
```coffee
# Before: function(arg) { var x = arg.x, y = arg.y; }
# After:  function({x, y}) {}
```
**Test**: Function parameters can destructure
**Commit**: "Add parameter destructuring"

### Phase 7: Modern Loops

#### Step 7.1: for...of Loops
**File**: `nodes.coffee` - `For.compileNode`
```coffee
# Before: for (i = 0; i < arr.length; i++) { x = arr[i]; }
# After:  for (const x of arr) {}
```
**Test**: Simple array iteration uses for...of
**Commit**: "Generate for...of loops"

## Testing Strategy

### For Each Step:
1. Create minimal test case in `test_es6.coffee`
2. Compile with `npm run build6`
3. Verify output in `v30/lib/coffeescript/test_es6.js`
4. Run the output in Node to ensure it works
5. Commit only after test passes

### Incremental Verification:
```bash
# After each commit:
cd v28
npm run build6
cd ../v30
node -c lib/coffeescript/*.js  # Syntax check all files
npm test  # Run test suite if available
```

## Common Pitfalls to Avoid

1. **Don't**: Try to implement all const/let logic at once
   **Do**: Start with obvious cases (never reassigned = const)

2. **Don't**: Convert all functions to arrows immediately
   **Do**: Start with simple cases, preserve 'function' where needed

3. **Don't**: Mix multiple transformations in one commit
   **Do**: One transformation type per commit

4. **Don't**: Assume ES6 features work everywhere
   **Do**: Remember v28/src/nodes.coffee must run in ES5

5. **Don't**: Forget about edge cases
   **Do**: Test with CoffeeScript's own codebase as the ultimate test

## Success Criteria

### v30 Output Should Have:
- [ ] All imports at top of file
- [ ] No `var` declarations (only const/let)
- [ ] Arrow functions where appropriate
- [ ] Native class syntax with fields
- [ ] Template literals for string interpolation
- [ ] Destructuring in parameters and assignments
- [ ] for...of loops instead of indexed iteration
- [ ] Clean, idiomatic ES6 that could be hand-written

### The Final Test:
```bash
cd v30
npm test  # All tests pass
npm run build  # Can compile itself
```

## Current Status

- [x] Basic setup of v28 and v30 directories
- [x] Solar parser integrated with backend.coffee
- [ ] Step 0.1: Nullish Coalescing Operator (??)
- [ ] Step 1.1: Basic Import/Export Syntax
- [ ] Step 1.2: Import Path Resolution
- [ ] Step 1.3: Import Hoisting
- [ ] (Continue with remaining steps...)

---

*This migration preserves CoffeeScript's semantics while generating modern, clean ES6 JavaScript.*