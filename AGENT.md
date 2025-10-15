# CoffeeScript ES6 Migration Roadmap

## Goal
Transform CoffeeScript to generate pure ES6 JavaScript output while maintaining backward compatibility through a careful bootstrap process.

## The Bootstrap Strategy

### Three-File Architecture
1. **v28/src/nodes5.coffee** - Generates ES5 (maintains backward compatibility)
2. **v28/src/nodes.coffee** - Generates ES6 but runs in ES5 environment (the bridge)
3. **v30/src/nodes.coffee** - Generates ES6 and uses ES6 syntax (the future)

### Build Process
- `npm run build` (in v28) - Uses nodes5.coffee for ES5 output
- `npm run build6` (in v28) - Uses nodes.coffee to compile v30/src → v30/lib with ES6 output
- `ES6=1` environment variable - Activates ES6 output mode

## Implementation Phases

### Phase 1: Nullish Coalescing Operator
Replace CoffeeScript's existential operator (`?`) with ES6's nullish coalescing (`??`).

**Implementation**: Modify `Op.compileExistence` in nodes.coffee
```coffee
compileExistence: (o, checkOnlyUndefined) ->
  left = @first.compileToFragments o, LEVEL_OP
  right = @second.compileToFragments o, LEVEL_OP
  answer = [].concat left, @makeCode(" ?? "), right
  if o.level <= LEVEL_OP then answer else @wrapInParentheses answer
```

**Impact**: Replaces ~30 lines of complex caching logic with 5 lines using native ES6 operator.

### Phase 2: Variable Declarations
Replace `var` with block-scoped `let` and `const` declarations.

**Approach**: Simple, maintainable rules aligned with CoffeeScript's philosophy:
- **Variables** → `let` (all regular variables)
- **Functions & Classes** → `const` (rarely reassigned)
- **Hoisting** → Maintain existing CoffeeScript behavior

**Implementation**: Simplify existing complex const/let analysis to just:
1. Replace `var` with `let` in hoisting logic
2. Add `const` for function and class assignments
3. Remove reassignment tracking complexity

**Rationale**: CoffeeScript users never write `let`/`const` directly. The compiler should prioritize simplicity and maintainability over ES6 style perfection. See `CONST_LET_PHILOSOPHY.md` for detailed reasoning.

### Phase 3: Module System (Import/Export)
Transform CommonJS modules to ES6 modules.

**Steps**:
1. Convert `require()` → `import`
2. Convert `exports` → `export`
3. Add `.js` extension to relative imports
4. Hoist all imports to top of file

**Example**:
```javascript
// Before (CommonJS)
const {helper} = require('./utils');
exports.myFunction = function() {};

// After (ES6)
import {helper} from './utils.js';
export const myFunction = function() {};
```

### Phase 4: Arrow Functions
Generate arrow functions where appropriate.

**Strategy**:
- Use arrows for simple functions without `this` context
- Preserve `function` keyword for constructors, generators, and methods using `this`
- Respect CoffeeScript's `=>` (bound) vs `->` (unbound) distinction

**Example**:
```javascript
// Simple function → Arrow
const double = (x) => x * 2;

// Method needing 'this' → Regular function
const handler = function() { return this.data; };
```

### Phase 5: Modern Loops
Use `for...of` for array iteration.

**Implementation**:
- Convert indexed loops to `for...of` when index isn't needed
- Maintain traditional loops when index is used
- Handle object iteration separately

**Example**:
```javascript
// Before
for (let i = 0, len = items.length; i < len; i++) {
  let item = items[i];
  process(item);
}

// After
for (const item of items) {
  process(item);
}
```

### Phase 6: Destructuring
Enable destructuring in parameters and assignments.

**Targets**:
- Function parameters: `({x, y}) => ...`
- Array destructuring: `[first, ...rest] = array`
- Object destructuring: `{name, age} = person`

### Phase 7: Class Enhancements
Modernize class syntax.

**Features**:
- Native class fields
- Static methods with `static` keyword
- Private fields (where applicable)

### Phase 8: Additional ES6 Features
Complete the transformation with:
- Optional chaining (`?.`)
- Spread operator (`...`)
- Default parameters
- Rest parameters
- Computed property names

## Testing Strategy

### Test Structure
Tests live in `v30/test/es6/` and use the existing test runner's `code()` function to verify output:

```coffee
# v30/test/es6/nullish_coalescing.coffee
code 'x = y ? "default"', 'let x = y ?? "default";'

# Run tests with:
# cd v30 && ES6=1 coffee test/runner.coffee test/es6/
```

### Verification Process
1. Write test cases for each transformation
2. Compile with `npm run build6` in v28
3. Verify output in v30/lib
4. Run compiled code to ensure correctness
5. Commit only after tests pass

## Implementation Guidelines

### Key Principles
1. **Incremental Progress** - One transformation per commit
2. **Maintain Compatibility** - v28/src/nodes.coffee must run in ES5
3. **Test Everything** - Each phase needs comprehensive tests
4. **Keep It Simple** - Avoid over-engineering transformations

### File Modifications
All ES6 transformations happen in two files:
- **v28/src/nodes.coffee** - The bridge compiler (CommonJS module format)
- **v30/src/nodes.coffee** - The pure ES6 compiler (ES6 module format)

Keep these files synchronized - changes in v28 should be mirrored in v30.

## Success Criteria

The migration is complete when v30 output exhibits:
- ✅ No `var` declarations (only `const`/`let`)
- ✅ ES6 module syntax (`import`/`export`)
- ✅ Arrow functions where appropriate
- ✅ Modern loop constructs (`for...of`)
- ✅ Destructuring assignments
- ✅ Native class syntax
- ✅ Clean, idiomatic ES6 that could be hand-written

### Ultimate Test
```bash
cd v30
npm test              # All tests pass
npm run build         # Can compile itself
node lib/index.js     # Runs successfully
```

## Current Status

### ✅ Completed
- Phase 1: Nullish Coalescing Operator

### 🚧 Next Up
- Phase 2: Variable Declarations (`let`/`const`) - **Approach decided, implementation pending**

### 📋 Upcoming
- Phase 3: Module System (Import/Export)
- Phase 4: Arrow Functions
- Phase 5: Modern Loops
- Phase 6: Destructuring
- Phase 7: Class Enhancements
- Phase 8: Additional ES6 Features

## Resources

- **Philosophy**: See `CONST_LET_PHILOSOPHY.md` for variable declaration design decisions
- **Test Suite**: `v30/test/es6/` contains all ES6 transformation tests
- **Bootstrap Details**: `v28/` contains the bridge compiler implementation

---

*This roadmap guides CoffeeScript's transformation to generate modern ES6 JavaScript while preserving the language's core philosophy of simplicity and elegance.*