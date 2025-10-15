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

## Incremental Implementation Plan (Ordered by Risk Level)

### Phase 0: Nullish Coalescing 🟢 LOW RISK (Start Here!)

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

### Phase 1: Template Literals 🟢 LOW RISK

#### Step 1.1: Basic String Interpolation
**File**: `nodes.coffee` - `StringWithInterpolations.compileNode`
```coffee
# Before: "Hello " + name + "!"
# After:  `Hello ${name}!`
```
**Why this is low risk**:
- Direct syntax transformation
- No scope analysis required
- No semantic changes
- Falls back gracefully if needed

**Test**: String interpolation uses template literals
**Commit**: "Use template literals for interpolation"

### Phase 2: Module System 🟢 LOW RISK

#### Step 2.1: Basic Import/Export Syntax
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

#### Step 2.2: Import Path Resolution
**File**: `nodes.coffee` - `ImportDeclaration.compileNode`
```coffee
# Auto-append .js to relative imports without extension
# './helpers' → './helpers.js'
# 'lodash' → 'lodash' (unchanged - npm package)
```
**Test**: Verify local imports get .js, packages don't
**Commit**: "Add .js extension to local imports"

#### Step 2.3: Import Hoisting
**File**: `nodes.coffee` - `Block.compileRoot`
```coffee
# Reorder: All imports to top, maintaining their relative order
# Before: Mixed imports throughout
# After:  All imports at top
```
**Test**: File with mixed imports/code compiles with imports first
**Commit**: "Hoist imports to top of file"

### Phase 3: Arrow Functions 🟡 MEDIUM RISK

#### Step 3.1: Simple Arrow Functions
**File**: `nodes.coffee` - `Code.compileNode`
```coffee
# Non-bound functions without 'this' usage
# Before: function(x) { return x * 2; }
# After:  (x) => x * 2
```
**Risk factors**:
- Must detect 'this' usage correctly
- Need to handle bound functions (=>) vs regular (->)
- Constructor detection

**Test**: Simple functions compile to arrows
**Commit**: "Generate arrow functions for simple cases"

#### Step 3.2: Preserve Traditional Functions
**File**: `nodes.coffee` - `Code.compileNode`
```coffee
# Keep 'function' for: constructors, generators, methods needing 'this'
# Detect via: @bound, @isGenerator, contains 'this' reference
```
**Test**: Class methods still use function syntax
**Commit**: "Preserve function keyword where needed"

### Phase 4: Modern Loops 🟡 MEDIUM RISK

#### Step 4.1: for...of Loops
**File**: `nodes.coffee` - `For.compileNode`
```coffee
# Before: for (i = 0; i < arr.length; i++) { x = arr[i]; }
# After:  for (const x of arr) {}
```
**Risk factors**:
- Need to detect when index is used
- Handle comprehensions correctly
- Preserve semantics for objects vs arrays

**Test**: Simple array iteration uses for...of
**Commit**: "Generate for...of loops"

### Phase 5: Variable Declarations 🔴 HIGH RISK

#### Step 5.1: Simple const for Never-Reassigned
**File**: `nodes.coffee` - `Block.compileWithDeclarations`
```coffee
# Variables that are assigned once and never reassigned
# Before: var x; x = 5;
# After:  const x = 5;
```
**Risk factors**:
- Requires full scope analysis
- Must track assignments across all code paths
- Closure complications

**Test**: Single assignment becomes const
**Commit**: "Use const for never-reassigned variables"

#### Step 5.2: let for Reassigned Variables
**File**: `nodes.coffee` - `Scope` class
```coffee
# Add tracking: markReassigned(name), isReassigned(name)
# Before: var x; x = 5; x = 10;
# After:  let x = 5; x = 10;
```
**Test**: Reassigned variables use let
**Commit**: "Track reassignments and use let"

#### Step 5.3: Inline Declarations
**File**: `nodes.coffee` - `Assign.compileNode`
```coffee
# Declare at first assignment instead of hoisting
# Before: var x, y; x = 5; y = 10;
# After:  const x = 5; const y = 10;
```
**Test**: No hoisted declarations for simple cases
**Commit**: "Inline variable declarations at first use"

### Phase 6: Class Improvements 🔴 HIGH RISK

#### Step 6.1: Class Fields
**File**: `nodes.coffee` - `Class.compileNode`
```coffee
# Use native class fields
# Before: constructor() { this.x = 5; }
# After:  class { x = 5; }
```
**Risk factors**:
- Initialization order matters
- Super class interactions
- Static vs instance fields

**Test**: Instance properties become class fields
**Commit**: "Use native class fields syntax"

#### Step 6.2: Static Methods
**File**: `nodes.coffee` - `Class.compileNode`
```coffee
# Before: MyClass.staticMethod = function() {}
# After:  class MyClass { static staticMethod() {} }
```
**Test**: Static methods use static keyword
**Commit**: "Generate static class methods"

### Phase 7: Destructuring 🔴 HIGH RISK

#### Step 7.1: Parameter Destructuring
**File**: `nodes.coffee` - `Param.compileNode`
```coffee
# Before: function(arg) { var x = arg.x, y = arg.y; }
# After:  function({x, y}) {}
```
**Risk factors**:
- Default values complexity
- Rest parameters interaction
- Nested destructuring patterns

**Test**: Function parameters can destructure
**Commit**: "Add parameter destructuring"

## Additional Recommendations

### 1. **Add Optional Chaining (Phase 0.5)**
Since we're implementing nullish coalescing (`??`), we should also add optional chaining (`?.`) as they're complementary operators:
```coffee
# CoffeeScript: user?.address?.street
# ES6 output: user?.address?.street
```
This pairs naturally with Phase 0 and is equally low-risk.

### 2. **Build Test Suite in v30/test/es6/**
Create comprehensive tests using the existing test runner's `code()` function:
```coffee
# v30/test/es6/nullish_coalescing.coffee
code 'x = y ? "default"', 'const x = y ?? "default";'
code 'func() ? "fallback"', 'func() ?? "fallback";'

# v30/test/es6/template_literals.coffee  
code '"Hello #{name}!"', '`Hello ${name}!`;'
code '"#{x} + #{y} = #{x+y}"', '`${x} + ${y} = ${x + y}`;'

# Run with: coffee test/runner.coffee test/es6/
```
The test runner already supports comparing compiled output, perfect for ES6 verification.

### 3. **Include Spread Operator (Phase 1.5)**
The spread operator (`...`) should be added early as it's low-risk:
```coffee
# Array spread: [...arr1, ...arr2]
# Object spread: {...obj1, ...obj2}
# Rest parameters: (first, ...rest) ->
```

### 4. **Document Breaking Changes**
Create a migration guide documenting any semantic differences:
- Temporal dead zone with let/const
- Class field initialization order
- Arrow function this-binding differences

### 5. **Performance Considerations**
Track and document performance impacts:
- Destructuring can be slower than direct access
- for...of is sometimes slower than indexed loops
- Template literals vs string concatenation performance

### 6. **Source Map Updates**
Ensure source maps remain accurate with ES6 transformations:
- Track how each transformation affects line/column mappings
- Test debugging experience in browsers and Node.js
- Verify stack traces remain useful

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

## Final Thoughts Before Starting

### Why Phase 0 (Nullish Coalescing) is Perfect
1. **One-function change** in `Op.compileExistence`
2. **Immediate visual impact** - 30 lines → 5 lines
3. **No dependencies** on other ES6 features
4. **Actually simplifies** the compiler (removes complexity)
5. **Native JavaScript** - no polyfills or compatibility issues

### Implementation Checklist for Phase 0
- [ ] Create `v30/test/es6/nullish_coalescing.coffee` with test cases
- [ ] Modify `v28/src/nodes.coffee` - `Op.compileExistence` method
- [ ] Run `npm run build6` in v28 to compile v30
- [ ] Run `coffee test/runner.coffee test/es6/` in v30 to verify
- [ ] Test with complex expressions (method calls, array access, etc.)
- [ ] Commit with message: "Replace existential operator with nullish coalescing (??)"

### Potential Edge Cases to Consider
- Chained existential operators: `a ? b ? c`
- Method calls: `obj.method?() ? default`
- Array/object access: `arr[i] ? obj.prop ? fallback`
- Inside other operators: `(a ? b) + (c ? d)`

### Success Metrics
- All existential operators (`?`) compile to `??`
- No temporary variables (`ref`) in simple cases
- Cleaner, more readable JavaScript output
- All existing tests still pass

## Current Status

### ✅ Completed
- [x] Basic setup of v28 and v30 directories
- [x] Solar parser integrated with backend.coffee

### 🟢 Low Risk (Next Up)
- [ ] Phase 0: Nullish Coalescing Operator (??)
- [ ] Phase 1: Template Literals
- [ ] Phase 2: Module System (Import/Export)

### 🟡 Medium Risk (After Low Risk Complete)
- [ ] Phase 3: Arrow Functions
- [ ] Phase 4: Modern Loops (for...of)

### 🔴 High Risk (Final Phases)
- [ ] Phase 5: Variable Declarations (const/let)
- [ ] Phase 6: Class Improvements
- [ ] Phase 7: Destructuring

---

*This migration preserves CoffeeScript's semantics while generating modern, clean ES6 JavaScript. Phases are ordered by implementation risk to maximize early wins and minimize complexity.*