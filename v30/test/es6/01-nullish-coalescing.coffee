# Phase 1: Nullish Coalescing Operator (??)

console.log "\n== Nullish Coalescing Operator =="

# Basic cases
code 'x = y ? "default"', '''
  let x;

  x = y ?? "default";
'''

code 'a = b ? c', '''
  let a;

  a = b ?? c;
'''

# Chained operators
code 'result = a ? b ? c', '''
  let result;

  result = a ?? b ?? c;
'''

# With function calls
code 'value = getData() ? getDefault()', '''
  let value;

  value = getData() ?? getDefault();
'''

# Property access
code 'name = user.name ? "Anonymous"', '''
  let name;

  name = user.name ?? "Anonymous";
'''

# Nested property access
code 'city = user.address?.city ? "Unknown"', '''
  let city;

  city = (typeof user.address !== "undefined" && user.address !== null ? user.address.city : void 0) ?? "Unknown";
'''

# In conditionals
code '''
  if value ? defaultValue
    doSomething()
''', '''
  if (value ?? defaultValue) {
    doSomething();
  }
'''

# As function argument
code 'process(data ? {})', '''
  process(data ?? {});
'''

# In return statements
code '''
  getValue = ->
    cache ? null
''', '''
  let getValue;

  getValue = () => cache ?? null;
'''

# Complex expressions
code 'result = (a + b) ? (c * d)', '''
  let result;

  result = (a + b) ?? (c * d);
'''

# With array access
code 'first = arr[0] ? "none"', '''
  let first;

  first = arr[0] ?? "none";
'''

# Multiple in one line
code 'x = a ? b; y = c ? d', '''
  let x, y;

  x = a ?? b;

  y = c ?? d;
'''

console.log "\n== Runtime Tests =="

# test is defined globally by the test runner
test "nullish coalescing with null", ->
  result = null ? "default"
  throw new Error("Expected 'default'") unless result is "default"

test "nullish coalescing with undefined", ->
  result = undefined ? "default"
  throw new Error("Expected 'default'") unless result is "default"

test "preserves falsy values", ->
  throw new Error("0 should be preserved") unless (0 ? "default") is 0
  throw new Error("false should be preserved") unless (false ? "default") is false
  throw new Error("empty string should be preserved") unless ("" ? "default") is ""

test "chained coalescing", ->
  result = null ? undefined ? "fallback"
  throw new Error("Expected 'fallback'") unless result is "fallback"

test "with existing value", ->
  result = "exists" ? "default"
  throw new Error("Expected 'exists'") unless result is "exists"