# Phase 4: Arrow Functions

console.log "\n== Arrow Functions =="

# Simple functions become arrows
code 'square = (x) -> x * x', '''
  let square;

  square = (x) => x * x;
'''

code 'add = (a, b) -> a + b', '''
  let add;

  add = (a, b) => a + b;
'''

# No parameters
code 'greet = -> "Hello"', '''
  let greet;

  greet = () => "Hello";
'''

# Block body
code '''
  process = (x) ->
    y = x * 2
    y + 1
''', '''
  let process;

  process = (x) => {
    let y;
    y = x * 2;
    return y + 1;
  };
'''

# Bound functions (fat arrow)
code '''
  class Button
    constructor: ->
      @handleClick = =>
        console.log @
''', '''
  let Button;

  Button = class Button {
    constructor() {
      this.handleClick = () => console.log(this);
    }

  };
'''

# Methods use regular functions
code '''
  obj =
    value: 42
    getValue: -> @value
''', '''
  let obj;

  obj = {
    value: 42,
    getValue: function() {
      return this.value;
    }
  };
'''

# Generators remain functions
code '''
  generator = ->
    yield 1
    yield 2
''', '''
  let generator;

  generator = function*() {
    yield 1;
    return (yield 2);
  };
'''

# Async arrow functions
code 'fetchData = (url) -> await fetch(url)', '''
  let fetchData;

  fetchData = async (url) => (await fetch(url));
'''

# IIFE with arrow functions
code '''
  result = do ->
    x = 5
    x * 2
''', '''
  let result;

  result = (() => {
    let x;
    x = 5;
    return x * 2;
  })();
'''

# Array methods with arrows
code 'doubled = numbers.map (x) -> x * 2', '''
  let doubled;

  doubled = numbers.map((x) => x * 2);
'''

code 'evens = numbers.filter (x) -> x % 2 == 0', '''
  let evens;

  evens = numbers.filter((x) => x % 2 === 0);
'''

# Nested arrow functions
code '''
  outer = (x) ->
    inner = (y) ->
      x + y
    inner
''', '''
  let outer;

  outer = (x) => {
    let inner;
    inner = (y) => x + y;
    return inner;
  };
'''

# Default parameters
code 'greet = (name = "World") -> "Hello #{name}"', '''
  let greet;

  greet = (name = "World") => `Hello ${name}`;
'''

# Rest parameters
code 'sum = (first, rest...) -> first + rest.length', '''
  let sum;

  sum = (first, ...rest) => first + rest.length;
'''

# Destructured parameters
code 'getName = ({name}) -> name', '''
  let getName;

  getName = ({name}) => name;
'''

console.log "\n== Runtime Tests =="

test "arrow functions work", 'square = ((x) -> x * x); square(3)', 9

test "single parameter", 'double = ((x) -> x * 2); double(5)', 10

test "arrow functions preserve lexical this", 'obj = { value: 42, getValueArrow: => @value }; typeof obj.getValueArrow', "function"

test "default parameters work", 'greet = ((name = "World") -> "Hello #{name}"); greet()', "Hello World"

test "default parameters with value", 'greet = ((name = "World") -> "Hello #{name}"); greet("Alice")', "Hello Alice"

test "rest parameters work", 'sum = ((first, rest...) -> first + rest.reduce ((a, b) -> a + b), 0); sum(1, 2, 3, 4)', 10