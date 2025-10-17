# Phase 6: Destructuring

console.log "\n== Destructuring =="

# Array destructuring
code '[a, b] = [1, 2]', '''
  let a, b;

  [a, b] = [1, 2];
'''

code '[first, second, third] = array', '''
  let first, second, third;

  [first, second, third] = array;
'''

# Array with rest
code '[head, tail...] = list', '''
  let head, tail;

  [head, ...tail] = list;
'''

code '[first, middle..., last] = array', '''
  let first, last, middle,
    splice = [].splice;

  [first, ...middle] = array, [last] = splice.call(middle, -1);
'''

# Object destructuring
code '{name, age} = person', '''
  let age, name;

  ({name, age} = person);
'''

code '{x, y, z} = coordinates', '''
  let x, y, z;

  ({x, y, z} = coordinates);
'''

# Nested destructuring
code '{user: {name, email}} = data', '''
  let email, name;

  ({
    user: {name, email}
  } = data);
'''

code '[{x, y}, {a, b}] = points', '''
  let a, b, x, y;

  [{x, y}, {a, b}] = points;
'''

# Aliasing
code '{name: userName, age: userAge} = user', '''
  let userAge, userName;

  ({
    name: userName,
    age: userAge
  } = user);
'''

# Default values
code '{name = "Anonymous", age = 0} = user', '''
  let age, name;

  ({name = "Anonymous", age = 0} = user);
'''

code '[a = 1, b = 2] = array', '''
  let a, b;

  [a = 1, b = 2] = array;
'''

# Function parameters
code '''
  greet = ({name, title = "Mr."}) ->
    "#{title} #{name}"
''', '''
  let greet;

  greet = ({name, title = "Mr."}) => `${title} ${name}`;
'''

code '''
  process = ([first, rest...]) ->
    console.log first, rest
''', '''
  let process;

  process = ([first, ...rest]) => console.log(first, rest);
'''

# Swapping variables
code '[a, b] = [b, a]', '''
  let a, b;

  [a, b] = [b, a];
'''

# Computed property names
code '''
  key = "dynamicKey"
  {[key]: value} = obj
''', '''
  let key, value;

  key = "dynamicKey";

  ({
    [key]: value
  } = obj);
'''

# Rest in objects
code '{a, b, rest...} = obj', '''
  let a, b, rest;

  ({a, b, ...rest} = obj);
'''

# Complex patterns
code '''
  [
    {name: firstName}
    {name: lastName}
  ] = people
''', '''
  let firstName, lastName;

  [
    {
      name: firstName
    },
    {
      name: lastName
    }
  ] = people;
'''

# In loops
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

console.log "\n== Runtime Tests =="

test "array destructuring", '[a, b, c] = [1, 2, 3]; a', 1

test "array destructuring b", '[a, b, c] = [1, 2, 3]; b', 2

test "object destructuring", '{x, y} = {x: 10, y: 20}; x', 10

test "object destructuring y", '{x, y} = {x: 10, y: 20}; y', 20

test "nested destructuring", '{user: {name}} = {user: {name: "Alice", age: 30}}; name', "Alice"

test "rest elements", '[first, rest...] = [1, 2, 3, 4]; first', 1

test "rest elements length", '[first, rest...] = [1, 2, 3, 4]; rest.length', 3

test "default values", '{name = "Anonymous"} = {}; name', "Anonymous"

test "swapping works", 'a = 1; b = 2; [a, b] = [b, a]; a', 2

test "swapping b value", 'a = 1; b = 2; [a, b] = [b, a]; b', 1