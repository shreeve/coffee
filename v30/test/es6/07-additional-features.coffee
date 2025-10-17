# Additional ES6 Features

# ==============================================================================
# OPTIONAL CHAINING (?.) - CoffeeScript's SUPERIOR Implementation
# ==============================================================================

console.log "\n== Optional Chaining (?.) - Better Than Native! =="

# CoffeeScript's optional chaining is MORE DEFENSIVE than JavaScript's native ?.
# It handles undeclared variables without throwing ReferenceError!

# Basic optional chaining with defensive checking
code 'value = obj?.property', '''
let value;

value = typeof obj !== "undefined" && obj !== null ? obj.property : void 0;
'''

# Method call with safe checking
code 'result = obj?.method()', '''
let result;

result = typeof obj !== "undefined" && obj !== null ? obj.method() : void 0;
'''

# Chained optional access - efficient short-circuit evaluation
code 'deep = obj?.level1?.level2?.value', '''
let deep, ref, ref1;

deep = typeof obj !== "undefined" && obj !== null ? (ref = obj.level1) != null ? (ref1 = ref.level2) != null ? ref1.value : void 0 : void 0 : void 0;
'''

# Optional array access - safe indexing
code 'item = arr?[0]', '''
let item;

item = typeof arr !== "undefined" && arr !== null ? arr[0] : void 0;
'''

# Optional function call - checks if it's actually a function!
code 'result = func?()', '''
let result;

result = typeof func === "function" ? func() : void 0;
'''

# Combining with nullish coalescing for defaults
code 'name = user?.profile?.name ? "Anonymous"', '''
let name, ref;

name = (typeof user !== "undefined" && user !== null ? (ref = user.profile) != null ? ref.name : void 0 : void 0) ?? "Anonymous";
'''

# Runtime tests proving it works perfectly
test '''
  obj = {a: {b: {c: 42}}}
  obj?.a?.b?.c
''', 42

test '''
  obj = null
  obj?.a?.b?.c
''', undefined

test '''
  # This would throw ReferenceError with native ?. but CoffeeScript handles it!
  # (We can't test undeclared vars in our test environment, but the compiled code proves it)
  declared = null
  declared?.property
''', undefined

# ==============================================================================
# SPREAD OPERATOR (...)
# ==============================================================================

console.log "\n== Spread Operator (...) =="

# Array spread in array literals
code 'combined = [first, ...rest, last]', '''
let combined;

combined = [first, ...rest, last];
'''

# Function call with spread
code 'Math.max(...numbers)', '''
  Math.max(...numbers);
'''

# Array destructuring with rest
code '[head, ...tail] = list', '''
let head, tail;

[head, ...tail] = list;
'''

# Object spread (ES2018, but often grouped with ES6)
code 'merged = {...defaults, ...options}', '''
let merged;

merged = {...defaults, ...options};
'''

# Function parameters with rest
code '''
  sum = (first, ...numbers) ->
    first + numbers.reduce((a, b) -> a + b)
''', '''
let sum;

sum = (first, ...numbers) => first + numbers.reduce((a, b) => a + b);
'''

# Runtime test for spread
test '''
  arr1 = [1, 2]
  arr2 = [3, 4]
  combined = [...arr1, ...arr2]
  combined.join(',')
''', "1,2,3,4"

test '''
  Math.max(...[1, 5, 3, 9, 2])
''', 9

# ==============================================================================
# DEFAULT PARAMETERS
# ==============================================================================

console.log "\n== Default Parameters =="

# Simple default parameter
code '''
  greet = (name = "World") ->
    "Hello, #{name}!"
''', '''
let greet;

greet = (name = "World") => `Hello, ${name}!`;
'''

# Multiple default parameters
code '''
  configure = (host = "localhost", port = 3000, ssl = false) ->
    {host, port, ssl}
''', '''
let configure;

configure = (host = "localhost", port = 3000, ssl = false) => ({host, port, ssl});
'''

# Default parameter with expression
code '''
  makeArray = (size = 10, fill = size * 2) ->
    Array(size).fill(fill)
''', '''
let makeArray;

makeArray = (size = 10, fill = size * 2) => Array(size).fill(fill);
'''

# Runtime test for defaults
test '''
  greet = (name = "Friend") -> "Hi, #{name}"
  greet()
''', "Hi, Friend"

test '''
  greet = (name = "Friend") -> "Hi, #{name}"
  greet("Alice")
''', "Hi, Alice"

# ==============================================================================
# REST PARAMETERS
# ==============================================================================

console.log "\n== Rest Parameters =="

# Rest parameters in functions (splats)
code '''
  collect = (first, second, ...others) ->
    others
''', '''
let collect;

collect = (first, second, ...others) => others;
'''

# Rest in the middle (CoffeeScript specialty)
code '''
  sandwich = (first, middle..., last) ->
    middle
''', '''
let sandwich,
  splice = [].splice;

sandwich = (first, ...middle) => {
  let last, ref;
  ref = middle, [...middle] = ref, [last] = splice.call(middle, -1);
  return middle;
};
'''

# Runtime test for rest parameters
test '''
  sum = (first, ...nums) ->
    first + nums.reduce ((a, b) -> a + b), 0
  sum(10, 1, 2, 3, 4)
''', 20

# ==============================================================================
# COMPUTED PROPERTY NAMES
# ==============================================================================

console.log "\n== Computed Property Names =="

# Computed property in object literal
code '''
  obj =
    [key]: value
    ["computed_" + name]: result
''', '''
let obj;

obj = {
  [key]: value,
  ["computed_" + name]: result
};
'''

# Computed property in class
code '''
  class Dynamic
    [methodName]: -> "dynamic"
''', '''
let Dynamic;

Dynamic = class Dynamic {
  [methodName]() {
    return "dynamic";
  }

};
'''

# Runtime test for computed properties
test '''
  key = "dynamicKey"
  obj = {[key]: 42}
  obj.dynamicKey
''', 42

# ==============================================================================
# TEMPLATE LITERALS (Already Working!)
# ==============================================================================

console.log "\n== Template Literals =="

# String interpolation becomes template literals
code 'message = "Hello, #{name}!"', '''
let message;

message = `Hello, ${name}!`;
'''

# Multi-line strings
code '''
  html = """
    <div>
      <h1>#{title}</h1>
      <p>#{content}</p>
    </div>
  """
''', '''
let html;

html = `<div>
  <h1>${title}</h1>
  <p>${content}</p>
</div>`;
'''

# Tagged template literals
code 'styled = css"color: #{color};"', '''
let styled;

styled = css`color: ${color};`;
'''

# Runtime test
test '''
  name = "ES6"
  "Welcome to #{name}!"
''', "Welcome to ES6!"

# ==============================================================================
# SHORTHAND PROPERTY SYNTAX
# ==============================================================================

console.log "\n== Shorthand Property Syntax =="

# Shorthand properties in object literals
code 'person = {name, age, email}', '''
let person;

person = {name, age, email};
'''

# Mixed shorthand and regular properties
code '''
  config = {
    host
    port: 8080
    secure
  }
''', '''
let config;

config = {
  host,
  port: 8080,
  secure
};
'''

# Runtime test
test '''
  x = 1
  y = 2
  point = {x, y}
  "#{point.x},#{point.y}"
''', "1,2"

# ==============================================================================
# FOR...OF LOOPS
# ==============================================================================

console.log "\n== for...of Loops =="

# Note: CoffeeScript's for...in compiles to traditional for loops, not for...of
# This is by design for compatibility and performance

code '''
  for item in items
    console.log item
''', '''
let i, item, len;

for (i = 0, len = items.length; i < len; i++) {
  item = items[i];
  console.log(item);
}
'''

# for...of would be more modern but CoffeeScript prioritizes compatibility
# This is intentional and aligns with our "simpler is better" philosophy

# ==============================================================================
# SYMBOLS (Partially Supported)
# ==============================================================================

console.log "\n== Symbols =="

# Symbol property access
code 'value = obj[Symbol.iterator]', '''
let value;

value = obj[Symbol.iterator];
'''

# Symbol in computed property
code '''
  obj =
    [Symbol.toStringTag]: "CustomObject"
''', '''
let obj;

obj = {
  [Symbol.toStringTag]: "CustomObject"
};
'''

# Runtime test
test '''
  obj = {[Symbol.toStringTag]: "MyType"}
  obj[Symbol.toStringTag]
''', "MyType"

# ==============================================================================
# SUMMARY STATUS
# ==============================================================================
