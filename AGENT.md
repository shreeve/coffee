# CoffeeScript Solar Directive Compiler - Agent Handoff

## Current Status: 280/326 tests passing (86%)

### Recent Session Achievements (260 → 280 = +20 tests)
1. **MASSIVE FIX: For loops & Comprehensions** (+20 tests!)
   - Fixed processUse bug: `o.index` is a literal number, not a position
   - Changed from `@$(o.index)` to just `o.index`
   - For loops: 1→13 tests passing (+12!)
   - Comprehensions: 0→8 tests passing (ALL 8 tests!)
   - Changed For grammar from 'Body $2' to direct position [1, 2]
2. **Fixed `unless` statements** - Proper condition inversion now works (+2 tests from previous)
   - Lexer converts UNLESS→IF with `tokenData.invert = true` flag
   - Grammar extracts invert flag via `{$use: 1, prop: 'invert}`
   - ES5 backend sets `type: 'unless'` when invert is true
   - If node's `processedCondition()` inverts when `type === 'unless'`
3. **Architecture discovery - THEN tokens**
   - THEN is handled by rewriter, NOT grammar rules!
   - Rewriter inserts INDENT/OUTDENT after THEN (line 722)
   - No need for explicit `WhileSource Expression` grammar rules
   - `while x < 10 then x++` works via implicit indentation

### Previous Achievements (235 → 258 = +23 tests)
1. **Fixed While loops** - Bodies now compile correctly (+12 tests)
2. **Fixed compound assignments** - `+=`, `-=`, etc. work properly
3. **Fixed string interpolation** - 12/14 tests pass (+11 tests)
4. **Fixed test runner** - Major breakthroughs with IIFE wrapping

### Current Architecture
- **es5.coffee**: 394 lines (very clean and modular)
- **Main entry**: `reduce()` method called by parser
- **Smart proxy**: `$()` function for resolving directive properties
- **Modular processing**: `processAst`, `processOps`, `processUse`, `processArr`
- **Deep resolution**: `_resolveNestedUse` for complex directive patterns

### Key Files
- `/Users/shreeve/Data/Code/coffee/cs290/src/es5.coffee` - Main ES5 backend
- `/Users/shreeve/Data/Code/coffee/cs290/src/syntax.coffee` - Grammar rules
- `/Users/shreeve/Data/Code/coffee/cs290/test/runner.coffee` - Test runner with IIFE fix
- `/Users/shreeve/Data/Code/coffee/cs290/src/lexer.coffee` - Handles unless→if conversion
- `/Users/shreeve/Data/Code/coffee/cs290/src/rewriter.coffee` - Handles THEN→INDENT/OUTDENT

### Test Runner Usage
```bash
cd /Users/shreeve/Data/Code/coffee/cs290
npm run test              # Run all tests
npm run parser           # Rebuild parser after syntax.coffee changes
npm run build            # Rebuild all CoffeeScript files
coffee test/runner.coffee test/es5/ast-If.coffee  # Run specific test
```

### Current Issues (66 tests remaining)

#### 1. **For loops - COMPLEX (empty body compilation)**
- Parser creates For nodes correctly
- Issue with `addSource` expecting AST nodes for all attributes
- Bodies compile as empty `for (...) {}`
- Related: Comprehensions also broken (`x * 2 for x in [1,2,3]`)

#### 2. **Class inheritance**
- `class B extends A` fails
- Need to implement extends handling

#### 3. **String interpolation edge cases (2 tests)**
- Functions in interpolation not working
- `"func: #{-> 5}"` and `"expr: #{(x) -> x + 1}"` fail

#### 4. **Range operations**
- `[1..5]` style ranges not working
- Need Range AST node implementation

#### 5. **Break/Continue statements**
- Need to implement as statement literals

### What's Working Well (260 tests!)
- ✅ Numbers, Booleans, Strings
- ✅ Arrays, Objects, indexing, property access
- ✅ Functions with bodies
- ✅ All operators (arithmetic, comparison, logical, `in`, `not`)
- ✅ Method calls (with and without arguments)
- ✅ **If/else, unless/else** (all 6 tests pass!)
- ✅ Switch/case statements
- ✅ Try/catch
- ✅ While/until loops with bodies
- ✅ Throw statements
- ✅ Array slicing
- ✅ String interpolation (12/14 tests)
- ✅ Compound assignments (+=, -=, etc.)
- ✅ Variable assignments and destructuring

### Important Architecture Notes
1. **Rewriter does preprocessing**
   - THEN→INDENT/OUTDENT (line 722)
   - UNLESS→IF with invert flag (lexer line 192)
   - Handles implicit indentation for single-liners
2. **Test runner wraps control flow** - Uses IIFE for if/while/try/switch/var
   - Clean regex test: `/(?:if \(|try \{|switch \(|var |while \()/.test(compiled)`
3. **Location data is crucial** - Always use `_ensureLocationData`
4. **While loop comprehension bug** - Simple while loops incorrectly generate `results = []` and `results.push()`
   - This is a compilation issue in nodes.coffee, NOT our ES5 backend
   - The AST is being built correctly, but nodes.coffee treats them as comprehensions
   - Example: `while x < 10 then x++` should NOT generate array collection code
5. **Node compilation phase** - Some issues are in nodes.coffee, not ES5 backend
6. **tokenData is the standard pattern** - Using `tokenData.invert = true` for UNLESS
   - Follows existing patterns: `tokenData.original`, `tokenData.parsedValue`, etc.
   - More explicit and debuggable than cs270's implicit token value preservation

### npm Scripts
```json
"scripts": {
  "parser": "coffee ../solar-es5.coffee -o lib/coffeescript/parser.js src/syntax.coffee",
  "build": "coffee -c -o lib/coffeescript src/*.coffee",
  "test": "coffee test/runner.coffee test/es5"
}
```

### Git Status
- Repository: https://github.com/shreeve/coffee
- Branch: main
- **Changes not committed yet** (per user request)
- Working directory has modifications to:
  - cs290/src/es5.coffee (unless fix, compound assignments, interpolation)
  - cs290/src/syntax.coffee (If rules for unless/invert flag, While rules cleaned up)
  - cs290/src/lexer.coffee (unless→if conversion with invert flag)
  - cs290/test/runner.coffee (IIFE wrapper with clean regex test)

### Next Steps for 100% (66 tests to go!)
1. **Fix For loops** - Main blocker for comprehensions (~15-20 tests)
2. **Implement Range nodes** - For `[1..5]` syntax (~5 tests)
3. **Add break/continue** - Statement literals (~5 tests)
4. **Fix class extends** - Inheritance handling (1 test)
5. **Complete string interpolation** - Function edge cases (2 tests)

### Quick Wins Available
- Break/continue statements (simple implementation)
- Class extends (single test to fix)
- String interpolation functions (2 tests)

### Debug Commands
```bash
# Test specific code
echo 'unless false then 10' | ./bin/coffee -bcs

# Debug with Solar output
echo 'for x in [1,2,3] then x' | SOLAR_DEBUG=1 ./bin/coffee -bcs 2>&1 | head -20

# Check compilation vs standard CoffeeScript
echo 'while x < 10 then x++' | coffee -bcs  # Standard CS 2.7.0
echo 'while x < 10 then x++' | ./bin/coffee -bcs  # Our implementation

# Find failing test categories
npm run test 2>&1 | grep "File: 0 passed"

# Test specific features
coffee test/runner.coffee test/es5/ast-If.coffee     # All 6 pass!
coffee test/runner.coffee test/es5/ast-While.coffee  # All 12 pass!
```

### Key Discovery: How CoffeeScript Handles Keywords
- **UNLESS**: Lexer converts to IF + invert flag, no UNLESS token exists
- **THEN**: Rewriter inserts INDENT/OUTDENT, no grammar rules needed
- **UNTIL**: Similar to UNLESS, converted to WHILE + invert flag
- This design keeps the grammar simpler by preprocessing in lexer/rewriter

## Mission: Get to 100% test compatibility - Only 66 tests remaining!
## We're at 80% - The final push is within reach!