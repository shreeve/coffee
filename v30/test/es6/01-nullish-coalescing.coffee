# Nullish Coalescing Operator (??)

# Runtime Tests

# Test 1: Basic existential operator
test '''
  y = null
  x = y ? "default"
  x
''', "default"

test '''
  y = "hello"
  x = y ? "default"
  x
''', "hello"

# Test 2: Chained existential operators
test '''
  a = null
  b = null
  c = "fallback"
  a ? b ? c
''', "fallback"

# Test 3: With method calls
test '''
  getData = -> null
  data = getData() ? {}
  typeof data
''', "object"

# Test 4: With property access
test '''
  obj = {}
  val = obj.prop ? 0
  val
''', 0

# Test 5: Inside expressions
test '''
  a = null
  b = 5
  sum = (a ? 0) + (b ? 0)
  sum
''', 5

# Test 6: Array prototype check
test '''
  method = Array::find ? null
  method isnt null
''', true

# Compilation Tests

# Basic cases
code 'x = y ? "default"', '''
let x;

x = y ?? "default";
'''

code 'a = b ? c', '''
let a;

a = b ?? c;
'''

# Chained existential operators
code 'result = a ? b ? c', '''
let result;

result = a ?? b ?? c;
'''

code 'val = w ? x ? y ? z', '''
let val;

val = w ?? x ?? y ?? z;
'''

# Method calls with existential
code 'data = getData() ? {}', '''
let data;

data = getData() ?? {};
'''

code 'result = obj.method() ? "fallback"', '''
let result;

result = obj.method() ?? "fallback";
'''

# Property access
code 'val = obj.prop ? 0', '''
let val;

val = obj.prop ?? 0;
'''

code 'item = arr[index] ? defaultItem', '''
let item;

item = arr[index] ?? defaultItem;
'''

# Inside expressions
code 'sum = (a ? 0) + (b ? 0)', '''
let sum;

sum = (a ?? 0) + (b ?? 0);
'''

code 'str = "Value: " + (val ? "none")', '''
let str;

str = "Value: " + (val ?? "none");
'''

# With function calls
code 'fn = callback ? (-> console.log "default")', '''
let fn;

fn = callback ?? (() => console.log("default"));
'''

# Array/object literals
code 'config = userConfig ? {timeout: 1000}', '''
let config;

config = userConfig ?? {
  timeout: 1000
};
'''

code 'items = list ? []', '''
let items;

items = list ?? [];
'''

# Prototype access (should work correctly)
code 'method = Array::find ? null', '''
let method;

method = Array.prototype.find ?? null;
'''

# Export with existential
code 'export value = data ? 42', '''
export let value = data ?? 42;
'''

# Inside conditionals
code 'if x ? y then z', '''
if (x ?? y) {
  z;
}
'''

# Complex expressions
code 'result = (obj?.prop ? backup).toString()', '''
let result;

result = ((obj != null ? obj.prop : void 0) ?? backup).toString();
'''

# Multiple on same line
code 'a = x ? 1; b = y ? 2', '''
let a, b;

a = x ?? 1;

b = y ?? 2;
'''

# In return statements
code '-> x ? "default"', '''
() => x ?? "default"
'''

# Test that it handles parentheses correctly
code 'val = (a ? b) ? c', '''
let val;

val = (a ?? b) ?? c;
'''

# Test with boolean false (should NOT use nullish coalescing for explicit boolean test)
# Note: CoffeeScript's ? is for null/undefined, not falsy values
code 'val = isEnabled ? true', '''
let val;

val = isEnabled ?? true;
'''
