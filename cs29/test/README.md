# Solar Directive Test Suite

Modern test suite for CoffeeScript 3.0 Solar directive processing.

## Architecture

**Test Runner:** `coffee runner.coffee` (uses global CoffeeScript 2.7.0)
**Test Format:** CoffeeScript files with `.test.coffee` extension
**Testing Target:** Local CoffeeScript implementation under test

## The Dual-Version System

This test suite uses two different CoffeeScript versions with distinct roles:

1. **Global CoffeeScript (2.7.0)** - The test runner environment
   - Interprets and executes the test runner script
   - Runs throughout the entire test process
   - Acts as the runtime environment for the test infrastructure

2. **Implementation Under Test** - The version being tested (e.g., cs29's 2.9.0)
   - Loaded as a library module via `require '../lib/coffeescript'`
   - Used only for compiling test code snippets
   - This is what we're actually testing

3. **Node.js Runtime** - Executes the compiled JavaScript
   - The compiled JavaScript from step 2 is executed via `eval()`
   - Runs in the neutral Node.js V8 engine

### Visual Flow

```
npm run test ../test/es5
    ↓
[Global Coffee 2.7.0] → Runs test/runner.coffee
    ↓
[Test Runner] → Loads ../lib/coffeescript (e.g., 2.9.0)
    ↓
[Test Code] → "class A then @x: 1"
    ↓
[Implementation 2.9.0] → Compiles to JavaScript
    ↓
[Node.js V8] → Executes: eval("(function() { ... })()")
    ↓
[Test Result] → Pass ✓ or Fail ✗
```

## How It Works

1. **Global CoffeeScript 2.7.0** runs the test runner script
2. **Test runner loads** the local implementation as a library
3. **Tests call** `CoffeeScript.compile()` on the implementation under test
4. **Compiled JavaScript** is executed via Node.js `eval()`
5. **Results compared** against expected behavior
6. **Console shows** test results and any failing directives

## Test Categories

### Basic Language (01-10)
- `01-basic.test.coffee` - Numbers, booleans, null, undefined
- `02-strings.test.coffee` - String literals, interpolation
- `03-operators.test.coffee` - +, -, *, /, ==, !=, etc.
- `04-assignment.test.coffee` - =, +=, ||=, etc.
- `05-variables.test.coffee` - Identifiers, scope basics
- `06-arrays.test.coffee` - [], [1,2,3], destructuring
- `07-objects.test.coffee` - {}, {a:1}, destructuring
- `08-ranges.test.coffee` - [1..5], [1...5], slicing
- `09-comments.test.coffee` - # comments, ### blocks ###
- `10-booleans.test.coffee` - true, false, and, or, not

### Functions & Control (11-20)
- `11-functions.test.coffee` - ->, =>, parameters, defaults
- `12-invocation.test.coffee` - Function calls, arguments
- `13-conditionals.test.coffee` - if, unless, else, postfix
- `14-loops.test.coffee` - while, until, loop
- `15-iteration.test.coffee` - for..in, for..of, comprehensions
- `16-control-flow.test.coffee` - break, continue, return
- `17-exceptions.test.coffee` - try, catch, finally, throw
- `18-switch.test.coffee` - switch, when, else
- `19-existence.test.coffee` - ?, ?=, ?., ?::
- `20-splats.test.coffee` - ..., function splats

### Advanced Features (21-30)
- `21-classes.test.coffee` - class, extends, super, @
- `22-async.test.coffee` - await, async functions
- `23-generators.test.coffee` - yield, yield from
- `24-modules.test.coffee` - import, export, from
- `25-destructuring.test.coffee` - {a,b} = obj, [x,y] = arr
- `26-regex.test.coffee` - ///, regex interpolation
- `27-jsx.test.coffee` - JSX syntax (if supported)
- `28-javascript.test.coffee` - Backtick JS literals
- `29-modern-syntax.test.coffee` - ??, ?., private fields
- `30-edge-cases.test.coffee` - Weird syntax, corner cases

## Usage

### Run Tests from Local Test Directory
```bash
npm run test test/                    # Run all local tests
npm run test test/01-basic.test.coffee  # Run single test file
```

### Run Shared Test Suite
```bash
npm run test ../test/es5               # Run all ES5 AST tests
npm run test ../test/es5/ast-Class.coffee  # Run specific test
npm run test ../test/old               # Run legacy test suite
```

### Add New Test
```coffee
# In appropriate category file:
test "description of what you're testing", ->
  result = CoffeeScript.compile('some CoffeeScript code')
  expected = eval(result)
  eq expected, expectedValue
```

## Development Workflow

1. **Add test** for new feature (test fails)
2. **See console output** showing test failures
3. **Implement/fix feature** in the implementation's source
4. **Recompile** the implementation
5. **Run test** again → closer to passing
6. **Repeat** until test passes

## File Organization

- **Easy to find** - Logical numbering and naming
- **Easy to add** - Drop test into appropriate category
- **Easy to reshuffle** - Just rename files
- **Room to grow** - 99 possible categories

## Notes

- Tests use global CoffeeScript (2.7.0) to run themselves
- The implementation under test gets loaded as a library via require
- Focus on **behavior**, not implementation details
- Perfect for test-driven development and regression testing
- The same test suite can be used across different implementations (cs29, cs290, etc.)
