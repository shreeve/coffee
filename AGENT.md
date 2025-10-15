# CoffeeScript ES6 Implementation Guide

*Transforming CoffeeScript for modern JavaScript: v27 → v28 → v30*

## Executive Summary

This guide documents the transformation of CoffeeScript from ES5 to ES6 output using Solar, an innovative parser generator that separates parsing from code generation through pure data directives. The key insight: CoffeeScript's AST doesn't commit to declaration types (`var`/`let`/`const`), enabling accurate ES6 generation through AST analysis and smart code generation. The goal is CoffeeScript 3.0.0 with clean, modern ES6 JavaScript output.

---

## Part 1: Understanding Solar Architecture

### The Innovation: Parser as Data Pipeline

Solar rethinks parser architecture by introducing a clean separation between parsing and code generation through declarative directives instead of imperative code.

#### Traditional Parser Architecture (Jison/YACC)
```
Source → Lexer → Parser → AST Generation → Code Output
                   ↓            ↓
                   └── Tightly Coupled ──┘
```
**Problems:**
- Grammar rules contain imperative code: `-> new If($2, $3)`
- Parser and AST generation are inseparable
- Slow: ~12.5 seconds to generate parser
- Single output target

#### Solar Architecture (Conceptual)
```
Source → Lexer → Parser → Directives → Backend → AST → Code Output
         (Fast)  (Solar)  (Pure Data)  (Smart)        (ES5/ES6/etc)
```
**Benefits:**
- Grammar contains only declarative directives
- Parser generates pure JSON-like data structures
- Fast: ~100ms to generate parser (125× faster)
- Multiple output targets from same directives

#### Solar Architecture (Actual Implementation)
```
Parse Rule → Directive → backend.reduce() → AST Node → Parse Stack
            (pure data)  (immediately)      (created)   (continues)
```

**Important:** While Solar conceptually enables complete tree analysis through pure data directives, the current implementation processes directives incrementally during parsing. Each directive is immediately converted to an AST node via `backend.reduce()` before the next rule is parsed. This works well for ES6 generation because CoffeeScript's AST nodes don't contain declaration types - those are added during code generation.

### Solar Directives: The Core Innovation

Solar directives are pure data structures that describe parse results without containing imperative code. This clean separation is the key innovation, regardless of when they're processed.

#### The Five Directive Types

##### 1. `$ast` - Node Type Declaration
Specifies which AST node type to create from a grammar rule.

```coffee
# Grammar rule
If: [
  o 'IF Expression Block',
    $ast: 'If'        # Create an If node
    condition: 2      # Stack position 2 → condition property
    body: 3          # Stack position 3 → body property
]

# Directive generated (pure data)
{
  $ast: 'If',
  condition: 2,  # Reference to stack position
  body: 3        # Reference to stack position
}

# AST node created immediately by backend
new If($2, $3)  # With actual values from parse stack
```

##### 2. `$use` - Value Transformation
References and transforms values from the parse stack.

```coffee
o 'STRING',
  $ast: 'StringLiteral',
  value: {$use: 1, method: 'slice', args: [1, -1]}  # Strip quotes
```

##### 3. `$ops` - Array Operations
Performs array manipulation and property setting.

```coffee
o 'Body TERMINATOR Line',
  $ops: 'array',
  append: [1, 3]  # Append item at position 3 to array at position 1
```

##### 4. `$arr` - Array Creation
Creates arrays from values with optional filtering.

```coffee
o 'AssignObj',
  $arr: [1]  # Wrap item at position 1 in an array
```

##### 5. `$loc` - Location Override (Rarely Needed)
Overrides automatic location tracking for special cases.

```coffee
# Default: Tracks all tokens automatically
o 'Expression PLUS Expression',
  $ast: 'Add'  # Location tracks positions 1-3

# Override: Track specific tokens only
o '( Expression )',
  $ast: 'Parens',
  $loc: 2  # Track only Expression, ignore parentheses
```

**Key Point:** Location data `[first_line, first_col, last_line, last_col]` is automatically tracked for ALL rules by the backend during AST node creation.

### How Solar Really Works: Incremental Processing

Unlike what pure directive architecture might suggest, Solar's current implementation processes directives incrementally:

#### During Parsing (Current Reality)
```javascript
// From solar parser generated code
const r = yy.backend && ((count, directive) =>
  yy.backend.reduce($$, _$, $$.length - 1, count, directive)
);

// Each grammar rule reduction:
// 1. Creates a directive (pure data)
// 2. Immediately calls backend.reduce()
// 3. Backend returns an AST node
// 4. AST node goes on parse stack
```

#### Backend Processing (Immediate)
```coffee
# From es5.coffee / es6.coffee backends
reduce: (values, positions, stackTop, symbolCount, directive) ->
  # Process directive immediately
  result = @processDirective(directive, values)  # Returns AST node
  result  # Goes back on parse stack
```

#### What This Means

1. **No complete directive tree exists** - directives are processed one by one
2. **AST is built incrementally** - just like traditional parsers, but cleaner
3. **AST nodes are uncommitted** - no `var`/`let`/`const` until code generation
4. **Two-pass compilation refers to AST traversal** - not directive processing
5. **The separation remains valuable** - declarative grammar vs imperative backend
6. **Well-suited for ES6** - all decisions can be made with complete AST knowledge

### Why Solar Still Enables ES6 Generation

Even with incremental processing, Solar's architecture provides key advantages:

1. **Clean Grammar**: Declarative directives instead of imperative code
2. **Multiple Backends**: Same directives can generate ES5 or ES6
3. **Fast Parser Generation**: 125× faster development iteration
4. **Maintainable Code**: Backend logic is centralized and testable

The two-pass approach for ES6 works with the complete AST:

**Pass 1 - AST Analysis:** (after parsing finishes)
- Traverse complete AST to collect information
- Track all variable assignments and reassignments
- Identify variables that escape their declaring scope
- Determine which loops can use for-of syntax
- Build a comprehensive scope map

**Pass 2 - Code Generation:** (with analysis results)
- Choose `const` for single-assignment variables
- Choose `let` for reassigned or escaping variables
- Generate for-of loops where appropriate
- Place declarations at optimal scope level
- No AST rewriting needed - just smart generation

---

## Part 2: Required Transformations

### A. Source File Transformations (CoffeeScript Code)

#### Priority 1: Module System Migration

**Transform CommonJS to ES6 Modules:**

```coffee
# BEFORE (ES5/CommonJS)
{compact, flatten} = require './helpers'
{isUnassignable} = require './lexer'

class Base
  # ...

exports.Base = Base
exports.extend = extend

# AFTER (ES6/ESM)
import {compact, flatten} from './helpers'
import {isUnassignable} from './lexer'

export class Base
  # ...

export {extend}
```

**Key Rules:**
- All imports must be at file top
- Use named exports for multiple exports
- Use default export for primary class/function
- No mixing of CommonJS and ESM

#### Priority 2: Class Export Patterns

```coffee
# BEFORE
exports.CodeFragment = class CodeFragment
exports.IdentifierLiteral = class IdentifierLiteral extends Literal

# AFTER
export class CodeFragment
export class IdentifierLiteral extends Literal
```

### B. Compiler Transformations (nodes.coffee Modifications)

#### 1. Variable Declaration Intelligence (AST-Based)

**Key Insight**: CoffeeScript's AST doesn't contain `var`/`let`/`const` - these are added during code generation, allowing informed ES6 decisions after AST analysis.

**Add to Scope class:**
```coffee
class Scope
  constructor: ->
    @variables = {}  # Track all variables
    @reassignments = {}  # Track which are reassigned
    @escapingVars = {}  # Track vars that escape blocks

  markReassigned: (name) ->
    @reassignments[name] = true

  markEscaping: (name) ->
    @escapingVars[name] = true

  isReassigned: (name) ->
    @reassignments[name] or @escapingVars[name] or false

  getDeclarationKeyword: (name) ->
    if @isReassigned(name) then 'let' else 'const'
```

**Add AST Analysis Pass:**
```coffee
class Block
  analyzeVariables: (o) ->
    # Complete AST exists - analyze it fully
    @traverseChildren false, (child) ->
      if child instanceof Assign
        name = child.variable.unwrap()?.value
        if o.scope.hasVariable(name)
          o.scope.markReassigned(name)
        else
          o.scope.add(name, 'var')

      # Check for escaping variables (try/catch, etc)
      if child instanceof Try
        @checkEscapingVars(child, o.scope)

  compileNode: (o) ->
    # First pass: analyze the complete AST
    @analyzeVariables(o)
    # Second pass: generate code with complete const/let knowledge
    @compileWithDeclarations(o)
```

#### 2. Import Hoisting

**Modify Block.compileRoot:**
```coffee
compileRoot: (o) ->
  # The AST is already built - reorganize for output
  imports = []
  others = []

  for exp in @expressions
    if exp instanceof ImportDeclaration
      imports.push exp
    else
      others.push exp

  # Compile imports first (they hoist)
  fragments = []
  fragments.push imp.compile(o) for imp in imports
  fragments.push other.compile(o) for other in others
  fragments
```

#### 3. For Loop Modernization

**Add logic to For node:**
```coffee
class For
  compile: (o) ->
    # Determine if we can use for...of
    if @canUseForOf()
      @compileForOf(o)
    else
      @compileTraditional(o)  # Use IIFE for complex cases

  canUseForOf: ->
    not @step and      # No 'by' clause
    not @guard and     # No 'when' clause
    not @pattern and   # Simple variable only
    @array?           # Iterating an array
```

---

## Part 3: ES6 Output Requirements

### Critical Priority (Must Have)

#### 1. Variable Declarations with const/let
```javascript
// ❌ CURRENT (ES5)
var a, b, c;
a = 1;
b = 2;
c = a + b;

// ✅ REQUIRED (ES6)
const a = 1;
const b = 2;
const c = a + b;
```

**Implementation**: Use AST traversal to analyze all assignments before generating any code.

#### 2. ES6 Module Syntax
```javascript
// ❌ CURRENT
const helpers = require('./helpers');
exports.MyClass = MyClass;

// ✅ REQUIRED
import helpers from './helpers';
export { MyClass };
```

#### 3. Block Scoping
```javascript
// ❌ CURRENT
for (var i = 0; i < len; i++) { }

// ✅ REQUIRED
for (let i = 0; i < len; i++) { }
```

### High Priority (Modern Patterns)

#### 4. For-Of Loops (when safe)
```javascript
// Current (always)
for (let i = 0, len = arr.length; i < len; i++) {
  const item = arr[i];
}

// Preferred (when no step/guard/comprehension)
for (const item of arr) {
}
```

#### 5. Destructuring with Declarations
```javascript
// ❌ CURRENT (breaks in strict mode)
({a, b} = obj);

// ✅ REQUIRED
const {a, b} = obj;
```

#### 6. Template Literals
```javascript
// Current
"Hello, " + name + "!"

// Preferred
`Hello, ${name}!`
```

### Nice to Have (Clean Code)

7. **Arrow Functions** for callbacks
8. **Spread Operator** replacing `slice.call`
9. **Object Shorthand** `{x}` instead of `{x: x}`
10. **Default Parameters** instead of `||` checks

---

## Part 4: Implementation Strategy

### Two-Pass AST Compilation

```
┌─────────────┐     ┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   Parser    │────▶│   Backend   │────▶│ Pass 1:      │────▶│ Pass 2:      │
│  (Solar)    │     │  (reduce)   │     │ AST Analysis │     │ Generation   │
└─────────────┘     └─────────────┘     └──────────────┘     └──────────────┘
       │                    │                    │                     │
   Directives          Create AST           Analyze AST          Generate ES6
  (incremental)        (incremental)         (complete)          with context
```

**Key Points**:
- The two-pass approach operates on the complete AST, not directives
- AST nodes don't contain `var`/`let`/`const` - just structure
- All ES6 decisions happen during code generation with full knowledge

### Actual Processing Flow

1. **During Parsing** (Incremental):
   - Grammar rule matches → directive created
   - `backend.reduce()` called immediately
   - Directive → AST node conversion
   - AST node placed on parse stack

2. **After Parsing** (Complete AST):
   - **Pass 1**: Traverse AST to analyze variables
   - **Pass 2**: Generate ES6 with analysis results

### Why Current Architecture Works for ES6

The incremental directive processing doesn't prevent ES6 generation because:

1. **AST is complete** before code generation starts
2. **Analysis happens on AST**, not directives
3. **Backends remain swappable** (ES5 vs ES6)
4. **Grammar stays clean** with declarative directives

### Why Incremental Processing Works Well for ES6

The current incremental directive → AST approach is **well-suited for ES6** because:

1. **CoffeeScript AST doesn't commit to declaration types**
   ```coffee
   # AST just represents structure, not var/let/const
   Assign {
     variable: IdentifierLiteral { value: 'x' }
     value: NumberLiteral { value: 5 }
   }
   # No "var" or "let" in the AST!
   ```

2. **Declaration keywords are chosen during code generation**
   ```coffee
   class Assign
     compile: (o) ->
       # Decision made here, not during parsing
       keyword = o.scope.getDeclarationKeyword(@variable.value)
       "#{keyword} #{@variable.value} = #{@value.compile(o)}"
   ```

3. **Complete AST provides all needed information**
   - Variable assignments and reassignments
   - Scope boundaries and escaping variables
   - Loop patterns for for-of conversion

**Recommendation**: Keep incremental processing. It's efficient and sufficient for ES6.

### Phase Implementation

**✅ Phase 1 (v27):** Traditional CoffeeScript with Jison
**✅ Phase 2 (v28):** Solar parser with ES5 output (incremental processing)
**🎯 Phase 3 (v30):** Solar parser with ES6 output (AST two-pass)

### Testing Strategy

1. **Unit Tests**: Each transformation tested independently
2. **Integration Tests**: Full programs compiled and executed
3. **Compatibility Tests**: Ensure ES5 → ES6 maintains semantics
4. **Performance Tests**: Verify compilation speed improvements

### Success Metrics

- ✅ All existing CoffeeScript tests pass
- ✅ Output runs in modern browsers without transpilation
- ✅ Code is idiomatic ES6 (passes ESLint recommended)
- ✅ Source maps work correctly
- ✅ Compilation remains fast (<200ms for typical files)

---

## Part 5: Key Insights & Reality Check

### What Solar Actually Provides

1. **Declarative Grammar**: Pure data directives instead of imperative code
2. **Clean Separation**: Grammar logic vs backend logic
3. **Fast Parser Generation**: 125× faster than Jison
4. **Backend Flexibility**: Same directives can target different outputs

### What Solar Doesn't Provide (Currently)

1. **Complete Directive Tree**: Directives are processed incrementally
2. **Directive-Level Analysis**: All analysis happens on the AST
3. **Fundamentally Different Architecture**: AST is still built during parsing

### Why Current Architecture Works Well for ES6

The incremental directive processing combined with AST analysis is well-suited for ES6 because:

- **AST Contains No Commitments**: No `var`/`let`/`const` in AST nodes - just pure structure
- **Complete AST Analysis**: Full AST is available for comprehensive variable analysis
- **Smart Code Generation**: Declaration keywords chosen during generation, not parsing
- **Clean Separation**: Grammar defines structure, backend chooses implementation
- **No Rewriting Needed**: AST stays as-is; ES6 decisions made during output

#### Example: How ES6 Generation Actually Works

```coffee
# CoffeeScript input
x = 5
if condition
  x = 10

# Step 1: Parse to AST (no var/let/const yet!)
Root
  ├── Assign { variable: 'x', value: 5 }
  └── If
      └── Assign { variable: 'x', value: 10 }

# Step 2: Analyze AST
# - Found: x assigned twice
# - Decision: x needs 'let'

# Step 3: Generate ES6
let x = 5;
if (condition) {
  x = 10;
}
```

The key: All the information needed for correct ES6 output exists in the AST.

### Building with ES6 Output

To compile with ES6 output from v28:
```bash
cd v28
ES6=1 npm run build6
```

This uses the ES6 backend when the `ES6` environment variable is set.

### Future Possibilities

Solar's architecture (even with incremental processing) enables:
- WebAssembly output
- Python/Ruby transpilation
- Custom language targets
- Optimization passes
- Type checking integration

---

## Appendix: Quick Reference

### Key Methods to Modify

**Variable Declaration & Scoping:**
- `Scope.add()` - Track variables and their usage patterns
- `Scope.getDeclarationKeyword()` - New method to determine const vs let
- `Scope.markReassigned()` - New method to track reassignments
- `Assign.compile()` - Generate const/let declarations instead of var

**Import/Export Statements:**
- `ImportDeclaration.compile()` - Generate ES6 import statements
- `ExportDeclaration.compile()` - Generate ES6 export statements
- `ExportNamedDeclaration.compile()` - Handle named exports
- `ExportDefaultDeclaration.compile()` - Handle default exports

**Block & Root Compilation:**
- `Root.compileRoot()` - Coordinate overall ES6 output structure
- `Block.compileRoot()` - Hoist imports to top of output
- `Block.analyzeVariables()` - New method for complete AST analysis
- `Block.compileWithDeclarations()` - Skip var hoisting for ES6

**Loop Transformations:**
- `For.compile()` - Generate for-of loops when appropriate
- `For.canUseForOf()` - New method to determine for-of eligibility

**Other ES6 Features (Optional):**
- `Code.compile()` - Potentially generate arrow functions
- `StringWithInterpolations.compile()` - Use template literals
- `Op.compile()` - Handle default parameters and spread operators

### How Directives Actually Flow
```
1. Parser reduces rule: IF Expression Block
2. Creates directive: {$ast: 'If', condition: 2, body: 3}
3. Calls backend.reduce(stack, positions, directive)
4. Backend processes: new If(stack[2], stack[3])
5. Returns AST node to parser
6. Parser continues with AST node on stack
```

---

## Required ES6 Improvements (To Be Implemented)

### Variable const/let Improvements Needed

1. **Variable Reassignment Tracking** (Scope Class)
   - Must add tracking to determine const vs let
   - Need methods: `markReassigned()`, `isReassigned()`, `getDeclarationKeyword()`
   - Should accurately identify which variables are reassigned throughout their lifecycle

2. **const/let Declarations** (Block.compileWithDeclarations)
   - Must replace `var` with appropriate `const`/`let`
   - Should group variables by reassignment status
   - Need to generate clean, modern variable declarations

3. **Inline Declarations** (Assign.compileNode)
   - Should emit `const`/`let` at first assignment instead of hoisting
   - Must track which variables are declared inline
   - Will produce more readable, less cluttered code

### Import/Export Improvements Needed

1. **Import Hoisting** (Block.compileRoot)
   - Must separate and reorder: imports → body → exports
   - Should ensure all imports appear at the top of the file
   - Need to maintain ES6 module semantics

2. **Smart Import Resolution** (ImportDeclaration)
   - Should auto-append `.js` to local paths without extensions
   - Must auto-add `assert { type: "json" }` for JSON imports
   - Need to handle modern module resolution patterns

3. **Import Formatting** (ModuleSpecifierList)
   - Should use succinct single-line for short import lists
   - Must use clean multi-line for longer lists
   - Will improve code readability

4. **Export Enhancements** (ExportDeclaration)
   - Must use proper `const`/`let` for exports based on reassignment
   - Should handle `export default class` correctly
   - Need to generate idiomatic ES6 export patterns

---

## The Three-File Bootstrap Strategy

To migrate CoffeeScript from ES5 to ES6 output, we use a three-file bootstrapping approach:

### File Structure and Purpose

1. **v28/src/nodes5.coffee** (Default ES5 Generator)
   - **Environment**: Runs in ES5 (Node.js)
   - **Generates**: ES5 JavaScript code
   - **Build**: `npm run build` from v28 directory
   - **Purpose**: Maintains backward compatibility; the current default for CoffeeScript 2.8.0

2. **v28/src/nodes.coffee** (Bridge ES6 Generator)
   - **Environment**: Runs in ES5 (must use CommonJS require/exports)
   - **Generates**: ES6 JavaScript code (import/export, const/let, arrow functions)
   - **Build**: `npm run build6` from v28 directory (compiles v30/src → v30/lib)
   - **Purpose**: The critical bridge that enables ES6 compilation while still running in ES5 environments
   - **Constraint**: Cannot use ES6 syntax itself since it must run in environments that only support ES5

3. **v30/src/nodes.coffee** (Future ES6 Generator)
   - **Environment**: Runs in ES6+ (uses import/export natively)
   - **Generates**: ES6 JavaScript code
   - **Build**: Will self-host once v30 is complete
   - **Purpose**: The fully modernized version that can use all ES6 features in its own source code
   - **Note**: Not used for self-hosting until the ES6 transition is complete

### Why This Strategy?

This approach allows CoffeeScript to bootstrap itself into the ES6 era without breaking existing ES5 environments. The v28/src/nodes.coffee file is the key innovation - it generates modern ES6 code while still being executable in legacy ES5 environments, enabling the compilation of the fully ES6-native v30 version.

---

*This document is the authoritative guide for implementing ES6 support in CoffeeScript 3.0.0 using Solar's incremental directive processing combined with AST analysis - an effective approach for ES6 generation since CoffeeScript AST nodes don't commit to declaration types.*
