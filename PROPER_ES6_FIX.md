# Proper ES6 Variable Declaration Fix

## The RIGHT Way to Fix This

We should NEVER add manual declarations like `match = null` to CoffeeScript source files.
Instead, the compiler (nodes6.coffee) should automatically detect these patterns and generate proper ES6 declarations.

## Key Patterns to Handle

### 1. Return Unless with Assignment
```coffee
return 0 unless match = REGEX.exec @chunk
```
Should compile to:
```javascript
let match;
if (!(match = REGEX.exec(this.chunk))) {
  return 0;
}
```

### 2. Destructuring with Fallback
```coffee
[quote] = STRING_START.exec(@chunk) || []
```
Should compile to:
```javascript
let quote;
[quote] = STRING_START.exec(this.chunk) || [];
```

### 3. Switch/When with Assignment
```coffee
switch
  when match = REGEX.exec @chunk
    doSomething()
```
Should compile to:
```javascript
let match;
switch (false) {
  case !(match = REGEX.exec(this.chunk)):
    doSomething();
}
```

### 4. The `in` Operator Problem
When CoffeeScript compiles `x in [a, b, c]`, it generates:
```javascript
(ref = x, [a, b, c].indexOf(ref) >= 0)
```
This creates temporary `ref` variables that need declaration.

## The Solution Components

1. **Enhanced Scope Analysis**: Track ALL assignments in ALL contexts
2. **Pre-compilation Pass**: Identify variables before generating code
3. **Smart Declaration Placement**: Put declarations at the right scope level
4. **Handle Generated Variables**: Account for compiler-generated temps like `ref`

## Why This Is Better

- **Clean Source**: CoffeeScript files remain readable
- **Automatic**: No manual intervention needed
- **Complete**: Handles all cases systematically
- **Maintainable**: Future patterns automatically handled
