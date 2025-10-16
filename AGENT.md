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
Replace `var` with `let` exclusively throughout all generated code.

**Approach**: Pure `let` philosophy aligned with CoffeeScript's core principle that everything is reassignable:
- **All declarations** → `let` (variables, functions, classes - everything)
- **No `const`** → Maintains CoffeeScript's semantic that all values can be reassigned
- **Hoisting** → Maintain existing CoffeeScript behavior

**Implementation**:
1. Replace all `var` declarations with `let`
2. No special cases for functions or classes - they use `let` like everything else
3. No reassignment tracking or analysis needed

**Rationale**: CoffeeScript treats all values as reassignable. Using `let` everywhere maintains perfect semantic compatibility while modernizing the output. See `CONST_LET_PHILOSOPHY.md` for detailed reasoning.

### Phase 3: Module System (Import/Export)
Support native ES6 import/export syntax in CoffeeScript.

**Approach**: Direct compilation of ES6 module syntax with minimal enhancements:
- Parse native import/export statements written in CoffeeScript
- **Require all static imports at the top of the file** (ES6 constraint, not auto-hoisted)
- Auto-add `.js` extension to relative imports (applies to both static and dynamic imports)
- Add `with { type: 'json' }` for `.json` imports
- Use `let` for all exports (consistent with Phase 2 philosophy)

**Import Positioning**: Static `import` statements must be placed at the top of files, matching ES6 semantics. This is intentional - no auto-hoisting or reordering. This educates users about ES6 module constraints and maintains code clarity.

**Dynamic Imports**: The `import()` function (not statement) is fully supported and can be used anywhere in code for conditional, lazy, or on-demand loading:
```coffeescript
# CoffeeScript - dynamic imports can be anywhere
if needsFeature
  {processData} = await import('./heavy-processor')
  processData(myData)

# Compiles to (note .js added automatically):
if (needsFeature) {
  ({processData} = await import('./heavy-processor.js'));
  processData(myData);
}
```

**Example**:
```coffeescript
# CoffeeScript input
import {helper} from './utils'
import data from './config.json'
export myFunction = -> console.log 'hello'

# ES6 output
import {helper} from './utils.js';
import data from './config.json' with { type: 'json' };
export let myFunction = function() { return console.log('hello'); };
```

**Note**: No CommonJS transformation - users write modern ES6 import/export syntax directly.

### Phase 4: Arrow Functions
Generate arrow functions where appropriate.

**Strategy**:
- **`=>` (fat arrow)** → Always generates JS arrow function (preserves `this` binding)
- **`->` (thin arrow)** → Use arrow when safe, function when needed:
  - Arrow when: No `this`, `arguments`, `super`, `new.target`
  - Function when: Constructors, generators, methods using `this`

**Success Metrics**:
- ✅ All `=>` become arrow functions
- ✅ Safe `->` cases use arrows (smaller output)
- ✅ No broken `this` contexts
- ✅ Special cases handled (generators, async, constructors)

**Example**:
```javascript
// CoffeeScript => always becomes arrow
let handler = () => this.handleEvent();

// CoffeeScript -> becomes arrow when safe
let double = (x) => x * 2;

// CoffeeScript -> stays function when needed
let method = function() { return this.data; };
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
for (let item of items) {
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
- ✅ No `var` declarations (only `let`)
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
- Phase 2: Variable Declarations (`let` only)
- Phase 3: Module System (Native ES6 import/export)
  - ✅ Auto-append `.js` to relative imports without extensions
  - ✅ Add `with { type: "json" }` for JSON imports
  - ✅ Use `let` for all exports (consistent with philosophy)
  - ✅ Smart import formatting (single-line ≤80 chars, packed multi-line >80)
  - ✅ Fixed `export default class` to generate valid ES6
  - ✅ Preserve explicit extensions (`.coffee`, `.ts`, `.css`, etc.)
  - 📊 **43/49 tests passing (88%)** - core functionality complete

### 🚧 In Progress
- Phase 4: Arrow Functions (0/33 tests passing)

### 📋 Upcoming
- Phase 5: Modern Loops
- Phase 6: Destructuring
- Phase 7: Class Enhancements
- Phase 8: Additional ES6 Features

### ℹ️ Notes
- Template literals are already supported in CoffeeScript (via backticks or interpolation)

## Resources

- **Philosophy**: See `CONST_LET_PHILOSOPHY.md` for variable declaration design decisions
- **Test Suite**: `v30/test/es6/` contains all ES6 transformation tests
- **Bootstrap Details**: `v28/` contains the bridge compiler implementation

---

*This roadmap guides CoffeeScript's transformation to generate modern ES6 JavaScript while preserving the language's core philosophy of simplicity and elegance.*