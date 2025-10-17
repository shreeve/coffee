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
  let city, ref;

  city = ((ref = user.address) != null ? ref.city : void 0) ?? "Unknown";
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

test "null returns default", 'null ? "default"', "default"

test "undefined returns default", 'undefined ? "default"', "default"

test "zero is preserved", '0 ? "default"', 0

test "false is preserved", 'false ? "default"', false

test "empty string is preserved", '"" ? "default"', ""

test "chained nullish operators", 'null ? undefined ? "fallback"', "fallback"

test "existing values preserved", '"exists" ? "default"', "exists"