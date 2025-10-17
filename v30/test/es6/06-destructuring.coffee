# Destructuring

# ==============================================================================
# OBJECT DESTRUCTURING
# ==============================================================================

console.log "\n== Object Destructuring =="

# Basic object destructuring
code '{name, age} = person', '''
let age, name;

({name, age} = person);
'''

# Object destructuring with renaming
code '{name: fullName, age: years} = person', '''
let fullName, years;

({
  name: fullName,
  age: years
} = person);
'''

# Object destructuring with defaults
code '{name = "Anonymous", age = 0} = user', '''
let age, name;

({name = "Anonymous", age = 0} = user);
'''

# Nested object destructuring
code '{user: {name, email}} = data', '''
let email, name;

({
  user: {name, email}
} = data);
'''

# Deep nested destructuring
code '{level1: {level2: {level3}}} = deep', '''
let level3;

({
  level1: {
    level2: {level3}
  }
} = deep);
'''

# Mixed destructuring with defaults and renaming
code '{name: userName = "Guest", role = "user"} = account', '''
let role, userName;

({
  name: userName = "Guest",
  role = "user"
} = account);
'''

# ==============================================================================
# ARRAY DESTRUCTURING
# ==============================================================================

console.log "\n== Array Destructuring =="

# Basic array destructuring
code '[first, second, third] = items', '''
let first, second, third;

[first, second, third] = items;
'''

# Array destructuring with rest/spread
code '[head, ...tail] = list', '''
let head, tail;

[head, ...tail] = list;
'''

# Array destructuring with skipping elements
code '[first, , third] = array', '''
let first, third;

[first, , third] = array;
'''

# Array destructuring with defaults
code '[x = 10, y = 20] = coords', '''
let x, y;

[x = 10, y = 20] = coords;
'''

# Nested array destructuring
code '[[a, b], [c, d]] = matrix', '''
let a, b, c, d;

[[a, b], [c, d]] = matrix;
'''

# Array destructuring with rest in middle (CoffeeScript splats)
code '[first, middle..., last] = items', '''
let first, last, middle,
  splice = [].splice;

[first, ...middle] = items, [last] = splice.call(middle, -1);
'''

# ==============================================================================
# FUNCTION PARAMETER DESTRUCTURING
# ==============================================================================

console.log "\n== Function Parameter Destructuring =="

# Object destructuring in function parameters
code 'process = ({name, age}) -> "#{name} is #{age}"', '''
let process;

process = ({name, age}) => `${name} is ${age}`;
'''

# Array destructuring in function parameters
code 'sum = ([x, y]) -> x + y', '''
let sum;

sum = ([x, y]) => x + y;
'''

# Nested destructuring in parameters
code 'display = ({user: {name, email}}) -> console.log name, email', '''
let display;

display = ({
    user: {name, email}
  }) => console.log(name, email);
'''

# Parameters with defaults
code 'greet = ({name = "Friend", greeting = "Hello"}) -> "#{greeting}, #{name}!"', '''
let greet;

greet = ({name = "Friend", greeting = "Hello"}) => `${greeting}, ${name}!`;
'''

# Mixed regular and destructured parameters
code 'fn = (regular, {opt1, opt2}) -> [regular, opt1, opt2]', '''
let fn;

fn = (regular, {opt1, opt2}) => [regular, opt1, opt2];
'''

# Rest parameters with destructuring
code 'process = ({name}, ...args) -> [name, args]', '''
let process;

process = ({name}, ...args) => [name, args];
'''

# ==============================================================================
# COMPLEX DESTRUCTURING PATTERNS
# ==============================================================================

console.log "\n== Complex Destructuring Patterns =="

# Mixed object and array destructuring
code '{data: [first, second]} = response', '''
let first, second;

({
  data: [first, second]
} = response);
'''

# Array of objects destructuring
code '[{name: name1}, {name: name2}] = users', '''
let name1, name2;

[
  {
    name: name1
  },
  {
    name: name2
  }
] = users;
'''

# Destructuring in for loops
code '''
  for {name, age} in users
    console.log name, age
''', '''
let age, i, len, name;

for (i = 0, len = users.length; i < len; i++) {
  ({name, age} = users[i]);
  console.log(name, age);
}
'''

# Destructuring with computed property names
code '{[key]: value} = obj', '''
let value;

({
  [key]: value
} = obj);
'''

# ==============================================================================
# DESTRUCTURING WITH THIS (@)
# ==============================================================================

console.log "\n== Destructuring with @ (this) =="

# Destructuring to instance variables
code '{@name, @age} = person', '''
({name: this.name, age: this.age} = person);
'''

# Destructuring in constructor
code '''
  class User
    constructor: ({@name, @email}) ->
''', '''
let User;

User = class User {
  constructor({name, email}) {
    this.name = name;
    this.email = email;
  }

};
'''

# ==============================================================================
# RUNTIME TESTS
# ==============================================================================

console.log "\n== Runtime Tests =="

# Test object destructuring works at runtime
test '''
  person = {name: "Alice", age: 30}
  {name, age} = person
  name + " is " + age
''', "Alice is 30"

# Test array destructuring works at runtime
test '''
  items = [1, 2, 3, 4, 5]
  [first, ...rest] = items
  first + rest.length
''', 5

# Test nested destructuring works at runtime
test '''
  data = {user: {name: "Bob", role: "admin"}}
  {user: {name, role}} = data
  "#{name}:#{role}"
''', "Bob:admin"

# Test parameter destructuring works at runtime
test '''
  greet = ({name, greeting = "Hi"}) -> "#{greeting} #{name}"
  greet({name: "Charlie"})
''', "Hi Charlie"

# Test destructuring with defaults works at runtime
test '''
  {x = 10, y = 20} = {x: 5}
  x + y
''', 25

# Test array destructuring with skipping works at runtime
test '''
  [a, , c] = [1, 2, 3]
  a + c
''', 4

# ==============================================================================
# EDGE CASES
# ==============================================================================

console.log "\n== Edge Cases =="

# Empty destructuring patterns
code '{} = obj', '''
  ({} = obj);
'''

code '[] = arr', '''
  arr;
'''

# Destructuring with prototype chain
code 'Array::push = null; {push} = []', '''
let push;

Array.prototype.push = null;

({push} = []);
'''

# Destructuring swap (should work without temp variable)
code '[a, b] = [b, a]', '''
let a, b;

[a, b] = [b, a];
'''

# ==============================================================================
# SUMMARY
# ==============================================================================
