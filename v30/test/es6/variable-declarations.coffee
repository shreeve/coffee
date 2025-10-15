###
Variable Declaration Tests for ES6 Output
==========================================

This test suite defines the expected ES6 output for all variable declaration scenarios.
We test var → let/const transformations following the simple philosophy:
- All variables use `let`
- Functions and classes use `const`
- Maintain CoffeeScript's hoisting behavior

Run with: cd v30 && ES6=1 coffee test/runner.coffee test/es6/variable-declarations.coffee
###

# ==============================================================================
# BASIC VARIABLE DECLARATIONS
# ==============================================================================

console.log "\n== Basic Variable Declarations =="

# Simple variable declarations use let (hoisted)
code 'x = 5', '''
let x;

x = 5;
'''
code 'name = "Alice"', '''
let name;

name = "Alice";
'''
code 'items = []', '''
let items;

items = [];
'''
code 'obj = {}', '''
let obj;

obj = {};
'''

# Variable reassignment still uses let (only one declaration)
code '''
  x = 5
  x = 10
  x = x + 1
''', '''
  let x;

  x = 5;

  x = 10;

  x = x + 1;
'''

# Multiple variable declarations
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

# ==============================================================================
# FUNCTION DECLARATIONS
# ==============================================================================

console.log "\n== Function Declarations =="

# Regular function declarations use const
code 'square = (x) -> x * x', '''
  const square = function(x) {
    return x * x;
  };
'''

# Arrow/bound functions use const
code 'handler = => @handleEvent()', '''
  const handler = () => {
    return this.handleEvent();
  };
'''

# Function with default parameters uses const
code 'greet = (name = "World") -> "Hello #{name}"', '''
  const greet = function(name = "World") {
    return `Hello ${name}`;
  };
'''

# Generator functions use const
code '''
  gen = ->
    yield 1
    yield 2
''', '''
  const gen = function*() {
    yield 1;
    return yield 2;
  };
'''

# Async functions use const
code '''
  fetchData = ->
    await fetch('/api')
''', '''
  const fetchData = async function() {
    return await fetch('/api');
  };
'''

# ==============================================================================
# CLASS DECLARATIONS
# ==============================================================================

console.log "\n== Class Declarations =="

# Class declarations use const
code '''
  class User
    constructor: (@name) ->
''', '''
  const User = class User {
    constructor(name) {
      this.name = name;
    }
  };
'''

# Class with inheritance uses const
code '''
  class Admin extends User
    constructor: -> super()
''', '''
  const Admin = class Admin extends User {
    constructor() {
      return super(...arguments);
    }
  };
'''

# Anonymous class expressions use const
code '''
  MyClass = class
    method: -> "result"
''', '''
  const MyClass = class {
    method() {
      return "result";
    }
  };
'''

# ==============================================================================
# HOISTING SCENARIOS
# ==============================================================================

console.log "\n== Hoisting Scenarios =="

# Hoisted variables in conditionals use let
code '''
  if condition
    x = 5
  else
    x = 10
  console.log x
''', '''
  let x;
  if (condition) {
    x = 5;
  } else {
    x = 10;
  }
  console.log(x);
'''

# Hoisted variables in nested conditionals
code '''
  if a
    if b
      result = "nested"
    else
      result = "not nested"
  console.log result
''', '''
  let result;
  if (a) {
    if (b) {
      result = "nested";
    } else {
      result = "not nested";
    }
  }
  console.log(result);
'''

# Variables declared after use are hoisted with let
code '''
  console.log x
  x = 5
''', '''
  let x;
  console.log(x);
  x = 5;
'''

# Function hoisting (functions are hoisted differently in CoffeeScript)
code '''
  console.log square(5)
  square = (x) -> x * x
''', '''
  let square;
  square = function(x) {
    return x * x;
  };
  console.log(square(5));
'''

# ==============================================================================
# LOOP VARIABLES
# ==============================================================================

console.log "\n== Loop Variables =="

# For-in loop variables use let
code '''
  for i in [1, 2, 3]
    console.log i
''', '''
  let i;
  for (i of [1, 2, 3]) {
    console.log(i);
  }
'''

# For-of loop variables use let
code '''
  for key of object
    console.log key
''', '''
  let key;
  for (key in object) {
    console.log(key);
  }
'''

# While loop variables declared inside use let
code '''
  while true
    x = getValue()
    break if x > 10
''', '''
  while (true) {
    let x = getValue();
    if (x > 10) {
      break;
    }
  }
'''

# Loop variables that escape scope are hoisted
code '''
  for item in items
    last = item
  console.log last
''', '''
  let item, last;
  for (item of items) {
    last = item;
  }
  console.log(last);
'''

# ==============================================================================
# DESTRUCTURING ASSIGNMENTS
# ==============================================================================

console.log "\n== Destructuring Assignments =="

# Object destructuring uses let (hoisted)
code '{name, age} = person', '''
let age, name;

({name, age} = person);
'''

# Array destructuring uses let (hoisted)
code '[first, second, third] = items', '''
let first, second, third;

[first, second, third] = items;
'''

# Nested destructuring uses let (hoisted)
code '{user: {name, email}} = data', '''
let email, name;

({
  user: {name, email}
} = data);
'''

# Destructuring with defaults uses let (hoisted)
code '{name = "Anonymous", age = 0} = user', '''
let age, name;

({name = "Anonymous", age = 0} = user);
'''

# Destructuring in function parameters
code 'process = ({name, age}) -> "#{name} is #{age}"', '''
  const process = function({name, age}) {
    return `${name} is ${age}`;
  };
'''

# ==============================================================================
# SCOPE AND SHADOWING
# ==============================================================================

console.log "\n== Scope and Shadowing =="

# Inner scope shadows outer variable
code '''
  x = 5
  do ->
    x = 10
    console.log x
  console.log x
''', '''
  let x = 5;
  (function() {
    let x = 10;
    return console.log(x);
  })();
  console.log(x);
'''

# Function scope creates new binding
code '''
  x = "outer"
  fn = ->
    x = "inner"
    x
''', '''
  let x = "outer";
  const fn = function() {
    let x = "inner";
    return x;
  };
'''

# ==============================================================================
# SPECIAL ASSIGNMENT PATTERNS
# ==============================================================================

console.log "\n== Special Assignment Patterns =="

# Compound assignments don't redeclare
code '''
  x = 5
  x += 10
  x *= 2
''', '''
  let x = 5;
  x += 10;
  x *= 2;
'''

# Chained assignments use let for hoisted declarations
code 'a = b = c = 5', '''
  let a, b, c;
  a = b = c = 5;
'''

# Conditional assignment uses let (with nullish coalescing from Phase 1)
code 'x = y ? "default"', '''
let x;

x = y ?? "default";
'''

# Logical assignment operators
code '''
  x = false
  x ||= true
  y = null
  y ??= "default"
''', '''
  let x, y;

  x = false;

  x ||= true;

  y = null;

  y ??= "default";
'''

# ==============================================================================
# EXPORT STATEMENTS (preparing for Phase 3)
# ==============================================================================

console.log "\n== Export Statements =="

# Note: These tests assume we're generating ES6 modules
# Currently CoffeeScript generates CommonJS, so these will fail
# until Phase 3 is implemented

# Exported variables use export let
# code 'export x = 5', 'export let x = 5;'

# Exported functions use export const
# code 'export process = (data) -> data * 2', '''
#   export const process = function(data) {
#     return data * 2;
#   };
# '''

# For now, test the current CommonJS output
code '''
  exports.x = 5
''', '''
  exports.x = 5;
'''

code '''
  exports.process = (data) -> data * 2
''', '''
  exports.process = function(data) {
    return data * 2;
  };
'''

# ==============================================================================
# TRY-CATCH BLOCKS
# ==============================================================================

console.log "\n== Try-Catch Blocks =="

# Variables in try-catch are scoped appropriately
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

# ==============================================================================
# SWITCH STATEMENTS
# ==============================================================================

console.log "\n== Switch Statements =="

# Variables in switch cases are hoisted
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

# ==============================================================================
# COMPREHENSIONS
# ==============================================================================

console.log "\n== Comprehensions =="

# Comprehension variables are scoped to expression
code 'doubled = (x * 2 for x in numbers)', '''
  let doubled = (function() {
    let results = [];
    let x;
    for (x of numbers) {
      results.push(x * 2);
    }
    return results;
  })();
'''

# Comprehension with filter
code 'evens = (x for x in numbers when x % 2 is 0)', '''
  let evens = (function() {
    let results = [];
    let x;
    for (x of numbers) {
      if (x % 2 === 0) {
        results.push(x);
      }
    }
    return results;
  })();
'''

# ==============================================================================
# EDGE CASES AND SPECIAL SCENARIOS
# ==============================================================================

console.log "\n== Edge Cases and Special Scenarios =="

# IIFE expressions don't affect outer scope
code '''
  result = do ->
    temp = 5
    temp * 2
  console.log result
''', '''
  let result = (function() {
    let temp = 5;
    return temp * 2;
  })();
  console.log(result);
'''

# Object method shorthand
code '''
  obj =
    method: -> "result"
    value: 5
''', '''
  let obj;

  obj = {
    method: function() {
      return "result";
    },
    value: 5
  };
'''

# Variables in string interpolation
code '''
  name = "World"
  greeting = "Hello #{name}"
''', '''
  let greeting, name;

  name = "World";

  greeting = `Hello ${name}`;
'''

# Rest parameters in functions
code '''
  sum = (first, rest...) ->
    first + rest.reduce((a, b) -> a + b, 0)
''', '''
  const sum = function(first, ...rest) {
    return first + rest.reduce(function(a, b) {
      return a + b;
    }, 0);
  };
'''

# Splat in array assignment
code '[head, tail...] = list', '''
let head, tail;

[head, ...tail] = list;
'''

# Existential assignment (should use nullish coalescing from Phase 1)
code 'x ?= 5', 'x ??= 5;'
code 'obj.prop ?= "default"', 'obj.prop ??= "default";'

# Do expressions with parameters
code 'result = do (x = 5) -> x * 2', '''
  let result;

  result = (function(x) {
    return x * 2;
  })(5);
'''

# Class with static methods
code '''
  class Util
    @staticMethod: -> "static"
    instanceMethod: -> "instance"
''', '''
  const Util = class Util {
    static staticMethod() {
      return "static";
    }

    instanceMethod() {
      return "instance";
    }

  };
'''

# ==============================================================================
# ADDITIONAL TEST CASES
# ==============================================================================

console.log "\n== Additional Test Cases =="

# Multiple assignments in one line
code 'x = 5; y = 10', '''
  let x, y;

  x = 5;

  y = 10;
'''

# Assignment in expression position
code 'console.log(x = 5)', '''
  let x;
  console.log(x = 5);
'''

# Nested functions
code '''
  outer = ->
    inner = ->
      "nested"
    inner()
''', '''
  const outer = function() {
    const inner = function() {
      return "nested";
    };
    return inner();
  };
'''

# Object with computed property names
code '''
  key = "dynamic"
  obj =
    [key]: "value"
''', '''
  let key, obj;

  key = "dynamic";

  obj = {
    [key]: "value"
  };
'''

# Function returning a function
code '''
  makeAdder = (x) ->
    (y) -> x + y
''', '''
  const makeAdder = function(x) {
    return function(y) {
      return x + y;
    };
  };
'''

console.log "\n== Test Complete =="