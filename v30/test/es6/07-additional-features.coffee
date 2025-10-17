# Phase 7: Additional ES6 Features

console.log "\n== Additional ES6 Features =="

# Template literals
code 'greeting = "Hello #{name}!"', '''
  let greeting;

  greeting = `Hello ${name}!`;
'''

code '''
  message = """
    Dear #{recipient},
    Thank you for #{action}.
    """
''', '''
  let message;

  message = `Dear ${recipient},
Thank you for ${action}.`;
'''

# Spread operator in arrays
code 'combined = [...arr1, ...arr2]', '''
  let combined;

  combined = [...arr1, ...arr2];
'''

code 'copy = [...original]', '''
  let copy;

  copy = [...original];
'''

# Spread in function calls
code 'Math.max(...numbers)', '''
  Math.max(...numbers);
'''

code 'fn(...args)', '''
  fn(...args);
'''

# Object spread
code 'merged = {...obj1, ...obj2}', '''
  let merged;

  merged = {
    ...obj1,
    ...obj2
  };
'''

code 'updated = {...user, name: "New Name"}', '''
  let updated;

  updated = {
    ...user,
    name: "New Name"
  };
'''

# Shorthand properties
code '''
  name = "Alice"
  age = 30
  person = {name, age}
''', '''
  let age, name, person;

  name = "Alice";

  age = 30;

  person = {name, age};
'''

# Computed property names
code '''
  key = "dynamic"
  obj = {[key]: value}
''', '''
  let key, obj;

  key = "dynamic";

  obj = {
    [key]: value
  };
'''

# Default parameters
code 'greet = (name = "World") -> "Hello #{name}"', '''
  let greet;

  greet = (name = "World") => `Hello ${name}`;
'''

code '''
  configure = (options = {}) ->
    console.log options
''', '''
  let configure;

  configure = (options = {}) => console.log(options);
'''

# Rest parameters
code 'sum = (first, rest...) -> first + rest.length', '''
  let sum;

  sum = (first, ...rest) => first + rest.length;
'''

# Optional chaining (defensive)
code 'value = obj?.prop?.nested', '''
  let value;

  value = typeof obj !== "undefined" && obj !== null && (obj.prop != null ? obj.prop.nested : void 0);
'''

code 'result = fn?()', '''
  let result;

  result = typeof fn === "function" ? fn() : void 0;
'''

# For-of loops
code '''
  for value of object
    console.log value
''', '''
  let value;

  for (value in object) {
    console.log(value);
  }
'''

# Symbols
code 'sym = Symbol("description")', '''
  let sym;

  sym = Symbol("description");
'''

# Tagged template literals
code 'result = tag"Hello #{name}"', '''
  let result;

  result = tag`Hello ${name}`;
'''

# Exponentiation
code 'squared = x ** 2', '''
  let squared;

  squared = x ** 2;
'''

code 'cubed = base ** 3', '''
  let cubed;

  cubed = base ** 3;
'''

console.log "\n== Runtime Tests =="

test "template literals", ->
  name = "World"
  greeting = "Hello #{name}!"
  throw new Error("Expected 'Hello World!'") unless greeting is "Hello World!"

test "spread in arrays", ->
  arr1 = [1, 2]
  arr2 = [3, 4]
  combined = [...arr1, ...arr2]
  throw new Error("Expected [1,2,3,4]") unless combined.length is 4

test "object spread", ->
  obj1 = {a: 1}
  obj2 = {b: 2}
  merged = {...obj1, ...obj2}
  throw new Error("Expected {a:1, b:2}") unless merged.a is 1 and merged.b is 2

test "default parameters", ->
  greet = (name = "World") -> "Hello #{name}"
  throw new Error("Expected 'Hello World'") unless greet() is "Hello World"

test "rest parameters", ->
  collectArgs = (first, rest...) -> rest
  args = collectArgs(1, 2, 3, 4)
  throw new Error("Expected [2,3,4]") unless args.length is 3

test "shorthand properties", ->
  x = 1
  y = 2
  point = {x, y}
  throw new Error("Expected {x:1, y:2}") unless point.x is 1 and point.y is 2

test "exponentiation", ->
  result = 2 ** 3
  throw new Error("Expected 8") unless result is 8