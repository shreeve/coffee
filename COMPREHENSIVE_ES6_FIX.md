# Comprehensive ES6 Variable Declaration Fix

## The Core Problem

Variables can be assigned in many contexts in CoffeeScript:
- `return 0 unless match = REGEX.exec()`
- `if match = REGEX.exec()`
- `while match = REGEX.exec()`
- `[a, b] = array`
- Switch/when statements
- And many more...

In ES6, ALL these variables need to be declared with `let` or `const`.

## The Comprehensive Solution

### Pass 1: Variable Discovery
Walk the ENTIRE AST and collect ALL variable assignments, regardless of context:
- Simple assignments: `x = 5`
- Destructuring: `[a, b] = arr`
- Conditional assignments: `if x = getValue()`
- Loop assignments: `while item = next()`
- Compiler-generated: `ref`, `ref1`, etc.

### Pass 2: Declaration Generation
For each scope, determine:
- Which variables need declaration
- Where to place declarations (appropriate scope level)
- Whether to use `let` or `const`

### Key Implementation Points

1. **Universal Assignment Detection**: Don't check specific node types, check ALL nodes for Assign instances
2. **Scope-Aware Collection**: Track which scope each assignment belongs to
3. **Proper Declaration Placement**: Declare at the right scope level
4. **Handle Generated Variables**: Track `freeVariable` calls

## Why Previous Attempts Failed

Previous attempts only handled specific patterns (If, While, etc.) but missed:
- Unless statements (which compile to `if not`)
- Complex destructuring patterns
- Nested assignments in expressions
- Compiler-generated temporaries

## The Right Way

Instead of patching individual node types, we need ONE comprehensive solution that works for ALL cases.
