# Fixing Lexer ES6 Compilation in nodes6.coffee

## The Problem

The lexer.coffee has many patterns that cause ES6 compilation issues:
1. Variables assigned in conditions: `if match = REGEX.exec(chunk)`
2. Variables assigned in while loops: `while match = REGEX.exec(str)`
3. Destructuring from conditional results: `[a, b, c] = match`
4. Mixed patterns: Some destructured vars are new, some are properties

## The Solution

Rather than hand-editing lexer.js (like parser.js), we should fix nodes6.coffee to handle these patterns automatically.

### Pattern 1: Conditional Variable Assignment

**CoffeeScript:**
```coffee
if match = REGEX.exec(@chunk)
  [value] = match
```

**Current BAD ES6 Output:**
```javascript
if (match = REGEX.exec(this.chunk)) {
  [value] = match;  // ReferenceError: match/value not defined
}
```

**Desired ES6 Output:**
```javascript
let match, value;
if (match = REGEX.exec(this.chunk)) {
  [value] = match;
}
```

### Pattern 2: While Loop Assignment

**CoffeeScript:**
```coffee
while match = REGEX.exec(str)
  doSomething(match)
```

**Desired ES6 Output:**
```javascript
let match;
while (match = REGEX.exec(str)) {
  doSomething(match);
}
```

### Pattern 3: Unless with Assignment

**CoffeeScript:**
```coffee
return 0 unless (match = WHITESPACE.exec @chunk) or
                (nline = @chunk.charAt(0) is '\n')
```

**Desired ES6 Output:**
```javascript
let match, nline;
if (!((match = WHITESPACE.exec(this.chunk)) ||
      (nline = this.chunk.charAt(0) === '\n'))) {
  return 0;
}
```

## Implementation in nodes6.coffee

We need to enhance these classes:

1. **If/Unless**: Already has `analyzeConditionalAssignments` - needs to be more comprehensive
2. **While/Until**: Need similar analysis
3. **Assign**: Better destructuring detection for all contexts

The key is to:
1. Detect ALL assignments in conditions
2. Hoist variable declarations to the appropriate scope
3. Handle both simple and destructuring assignments

## Why This Is Better Than Hand-Editing

1. **Automatic**: No manual intervention needed
2. **Consistent**: All files compiled the same way
3. **Maintainable**: Future changes automatically handled
4. **Complete**: Fixes the root cause, not symptoms
