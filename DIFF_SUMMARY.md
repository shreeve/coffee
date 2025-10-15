# Summary of Changes to v28/src/nodes5.coffee

**Note**: These changes were made to `v28/src/nodes5.coffee` which is the ES5-compatible version with conditional ES6 support. Similar changes (without the `process.env.ES6` checks) were also applied to `v30/src/nodes.coffee` for pure ES6 output.

## 1. Scope Class - Variable Reassignment Tracking
**Purpose**: Track which variables are reassigned to determine `const` vs `let`

### Added to constructor:
```coffee
@reassignments = {}  # Track which variables are reassigned
```

### New methods:
```coffee
markReassigned: (name) ->
  # Mark variable as reassigned in current or parent scope

isReassigned: (name) ->
  # Check if variable has been reassigned

getDeclarationKeyword: (name) ->
  # Return 'const' or 'let' based on reassignment status
```

### Modified `find()` method:
- Calls `markReassigned()` when a variable is found (indicating reassignment)

---

## 2. Block.compileRoot - Import Hoisting
**Purpose**: Move all import statements to the top of the generated JS file

### Changes:
- Separates expressions into `imports`, `exports`, and `others`
- Compiles imports first, then body, then exports
- Adds proper spacing between sections

---

## 3. Block.compileWithDeclarations - const/let Variable Declarations
**Purpose**: Replace `var` with `const`/`let` in ES6 mode

### Changes:
- Groups variables by declaration type:
  - Variables with assignments → handled inline
  - Variables that are reassigned → `let`
  - Variables never reassigned → `let` (since they're hoisted without initializers)
- Skips variables marked as `declaredInline`
- Only emits `var` in non-ES6 mode

---

## 4. ImportDeclaration.compileNode - Smart Import Resolution
**Purpose**: Automatically append `.js` to local paths and add JSON assertions

### Changes:
- Checks if source is a local path (`./`, `../`, `/`)
- Appends `.js` if local path has no extension
- Automatically adds `assert { type: "json" }` for `.json` imports
- Leaves bare module specifiers unchanged

---

## 5. ExportDeclaration.compileNode - Export Enhancements
**Purpose**: Proper ES6 export syntax with const/let

### Changes:
- Uses `const` by default for exports
- Switches to `let` if variable is reassigned
- Handles `export default class Name` properly (avoids double assignment)
- Applies same smart import resolution for re-exports
- Adds JSON assertions for JSON re-exports

---

## 6. Assign.compileNode - Inline Variable Declarations
**Purpose**: Emit `const`/`let` declarations at first assignment

### Changes:
- Checks if assignment should be a declaration in ES6 mode
- Tracks variables declared inline via `o.scope.declaredInline`
- Emits `const` or `let` based on reassignment analysis
- Skips if variable already in scope (parameter, outer scope)

---

## 7. Op.compileExistence - Nullish Coalescing Operator
**Purpose**: Use modern `??` operator instead of complex null checks

### Changes:
```coffee
compileExistence: (o, checkOnlyUndefined) ->
  # Use nullish coalescing in ES6 mode
  if process.env.ES6
    left = @first.compileToFragments o, LEVEL_OP
    right = @second.compileToFragments o, LEVEL_OP
    answer = [].concat left, @makeCode(" ?? "), right
    return if o.level <= LEVEL_OP then answer else @wrapInParentheses answer

  # Original implementation for ES5...
```

### Benefits:
- Eliminates temporary `ref` variables
- Fixes export with existential operator issue
- Generates cleaner, modern JavaScript
- Better performance (native operator)

---

## 8. ModuleSpecifierList.compileNode - Succinct Import Formatting
**Purpose**: Format import/export specifier lists nicely

### Changes:
- Single-line for short lists (≤4 specifiers and <80 chars)
- Multi-line for longer lists
- Proper indentation and comma placement

---

## Key Implementation Details

### ES6 Detection:
All ES6-specific changes are controlled by `process.env.ES6` flag:
```coffee
if process.env.ES6
  # ES6-specific code
else
  # ES5 fallback
```

### Scope Tracking:
- `declaredInline`: Tracks variables declared with const/let inline
- `reassignments`: Tracks which variables are reassigned
- Both are used to determine proper declaration keywords

### Build Process:
```bash
# From v28 directory
ES6=1 ./bin/coffee -bc -o ../v30/lib/coffeescript ../v30/src/*.coffee
```

The `ES6=1` environment variable enables all these transformations.
