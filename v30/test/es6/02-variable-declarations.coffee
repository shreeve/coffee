# Phase 2: Variable Declarations (pure let)

console.log "\n== Variable Declarations =="

# Basic declarations
code 'x = 5', '''
  let x;

  x = 5;
'''

code 'name = "Alice"', '''
  let name;

  name = "Alice";
'''

# Multiple declarations
code '''
  a = 1
  b = 2
  c = 3
''', '''
  let a, b, c;

  a = 1;

  b = 2;

  c = 3;
'''

# Destructuring assignment
code '[x, y] = [1, 2]', '''
  let x, y;

  [x, y] = [1, 2];
'''

code '{name, age} = person', '''
  let age, name;

  ({name, age} = person);
'''

# Functions use let
code 'square = (x) -> x * x', '''
  let square;

  square = (x) => x * x;
'''

# Arrow functions
code 'handler = => @handleEvent()', '''
  let handler;

  handler = () => this.handleEvent();
'''

# Async functions
code 'fetchData = -> await fetch("/api")', '''
  let fetchData;

  fetchData = async () => (await fetch("/api"));
'''

# Generators
code '''
  counter = ->
    yield 1
    yield 2
''', '''
  let counter;

  counter = function*() {
    yield 1;
    return (yield 2);
  };
'''

# Class declarations
code '''
  class Person
    constructor: (@name) ->
''', '''
  let Person;

  Person = class Person {
    constructor(name) {
      this.name = name;
    }

  };
'''

# For loops
code '''
  for i in [1, 2, 3]
    console.log i
''', '''
  let i, j, len, ref;

  ref = [1, 2, 3];
  for (j = 0, len = ref.length; j < len; j++) {
    i = ref[j];
    console.log(i);
  }
'''

# While loops
code '''
  while condition
    x = getValue()
    break if x > 10
''', '''
  let x;

  while (condition) {
    x = getValue();
    if (x > 10) {
      break;
    }
  }
'''

# Try-catch
code '''
  try
    result = riskyOperation()
  catch error
    result = "failed"
  console.log result
''', '''
  let error, result;

  try {
    result = riskyOperation();
  } catch (error1) {
    error = error1;
    result = "failed";
  }

  console.log(result);
'''

# Switch statements
code '''
  switch value
    when 1
      result = "one"
    when 2
      result = "two"
    else
      result = "other"
  console.log result
''', '''
  let result;

  switch (value) {
    case 1:
      result = "one";
      break;
    case 2:
      result = "two";
      break;
    default:
      result = "other";
  }

  console.log(result);
'''

# Comprehensions
code 'doubled = (x * 2 for x in numbers)', '''
  let doubled, x;

  doubled = (() => {
    let i, len, results;
    results = [];
    for (i = 0, len = numbers.length; i < len; i++) {
      x = numbers[i];
      results.push(x * 2);
    }
    return results;
  })();
'''

# IIFE expressions
code '''
  result = do ->
    temp = 5
    temp * 2
  console.log result
''', '''
  let result;

  result = (() => {
    let temp;
    temp = 5;
    return temp * 2;
  })();

  console.log(result);
'''

# Object methods
code '''
  obj =
    method: -> "result"
    value: 5
''', '''
  let obj;

  obj = {
    method: () => "result",
    value: 5
  };
'''

# String interpolation
code '''
  name = "World"
  greeting = "Hello #{name}"
''', '''
  let greeting, name;

  name = "World";

  greeting = `Hello ${name}`;
'''

# Rest parameters
code '''
  sum = (first, rest...) ->
    first + rest.reduce ((a, b) -> a + b), 0
''', '''
  let sum;

  sum = (first, ...rest) => first + rest.reduce(((a, b) => a + b), 0);
'''

# Splat in arrays
code '[head, tail...] = list', '''
  let head, tail;

  [head, ...tail] = list;
'''

# Existential assignment
code '''
  x = undefined
  x ?= 5
''', '''
  let x;

  x = void 0;

  x ??= 5;
'''

# Logical assignment
code '''
  x = false
  x ||= true
  y = null
  y ?= "default"
''', '''
  let x, y;

  x = false;

  x || (x = true);

  y = null;

  y ??= "default";
'''

console.log "\n== Runtime Tests =="

test "variable assignment", 'x = 10; x', 10

test "array destructuring first", '[a, b] = [1, 2]; a', 1
test "array destructuring second", '[a, b] = [1, 2]; b', 2

test "object destructuring x", '{x, y} = {x: 5, y: 10}; x', 5
test "object destructuring y", '{x, y} = {x: 5, y: 10}; y', 10

test "template literals", 'name = "World"; "Hello #{name}"', "Hello World"

test "rest parameters", '((first, rest...) -> rest.length)(1, 2, 3, 4)', 3

test "default parameter unused", '((x = 5) -> x)()', 5
test "default parameter overridden", '((x = 5) -> x)(10)', 10