# Solar Directive Test Suite

Modern test suite for CoffeeScript 3.0 Solar directive processing.

## Architecture

**Test Runner:** `coffee runner.coffee` (uses global CoffeeScript 2.7.0)
**Test Format:** CoffeeScript files with `.test.coffee` extension
**Testing Target:** Our cs290 Solar directive implementation

## How It Works

1. **Global CoffeeScript** compiles and runs test files
2. **Test files** import our cs290 implementation
3. **Tests call** `CoffeeScript.compile()` on our implementation
4. **Results compared** against expected behavior
5. **Console shows** which Solar directives need implementation

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

### Run All Tests
```bash
cd test && coffee runner.coffee
```

### Run Single Category (Future)
```bash
cd test && coffee runner.coffee 01-basic.test.coffee
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
2. **See console output** showing missing Solar directives
3. **Implement directive** in `src/es6.coffee`
4. **Recompile:** `coffee -c -o lib/coffeescript src/es6.coffee`
5. **Run test** again → closer to passing
6. **Repeat** until test passes

## File Organization

- **Easy to find** - Logical numbering and naming
- **Easy to add** - Drop test into appropriate category
- **Easy to reshuffle** - Just rename files
- **Room to grow** - 99 possible categories

## Notes

- Tests use global CoffeeScript to run themselves
- Our cs290 implementation gets tested through require
- Focus on **behavior**, not implementation details
- Perfect for test-driven Solar directive development
