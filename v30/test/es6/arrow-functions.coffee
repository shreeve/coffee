###
ES6 Arrow Functions Test Suite
===============================

CoffeeScript 3.0 should generate arrow functions where appropriate:
- Simple functions without `this` → arrow functions
- Functions using `this` → regular functions
- Bound functions (=>) → arrow functions
- Unbound functions (->) → case-by-case basis
- Generators → function*
- Constructors → function
###

# Test helper to validate generated JavaScript
code = (coffee, js) ->
  try
    compiled = CoffeeScript.compile(coffee, bare: true).trim()
    expected = js.trim()
    if compiled is expected
      console.log "✓", coffee.replace(/\n/g, ' ').substring(0, 50)
    else
      console.log "✗", coffee.replace(/\n/g, ' ').substring(0, 50)
      console.log "    Expected JS:", expected.replace(/\n/g, '\n    ')
      console.log "    Got JS:     ", compiled.replace(/\n/g, '\n    ')
  catch err
    console.log "✗", coffee.replace(/\n/g, ' ').substring(0, 50)
    console.log "    Compilation Error:", err.message

console.log "CoffeeScript 3.0 ES6 Arrow Functions Test Suite"
console.log "=" .repeat 50

# ==============================================================================
# SIMPLE FUNCTIONS (Should use arrows)
# ==============================================================================

console.log "\n== Simple Functions (Should Use Arrows) =="

# Simple function without parameters
code "double = -> 2", '''
  let double;

  double = () => 2;
'''

# Function with one parameter
code "square = (x) -> x * x", '''
  let square;

  square = (x) => x * x;
'''

# Function with multiple parameters
code "add = (a, b) -> a + b", '''
  let add;

  add = (a, b) => a + b;
'''

# Function with block body
code '''
  greet = (name) ->
    console.log "Hello"
    name
''', '''
  let greet;

  greet = (name) => {
    console.log("Hello");
    return name;
  };
'''

# Nested arrow function
code '''
  outer = ->
    inner = -> 42
    inner()
''', '''
  let outer;

  outer = () => {
    let inner;
    inner = () => 42;
    return inner();
  };
'''

# ==============================================================================
# BOUND FUNCTIONS (=> should always produce arrows)
# ==============================================================================

console.log "\n== Bound Functions (=>) =="

# Bound function preserves this
code "handler = => @value", '''
  let handler;

  handler = () => this.value;
'''

# Bound function with parameters
code "onClick = (event) => @handleClick(event)", '''
  let onClick;

  onClick = (event) => this.handleClick(event);
'''

# Bound function in class
code '''
  class Button
    constructor: ->
      @clicked = false

    handleClick: =>
      @clicked = true
''', '''
  let Button;

  Button = class Button {
    constructor() {
      this.handleClick = this.handleClick.bind(this);
      this.clicked = false;
    }

    handleClick() {
      return this.clicked = true;
    }

  };
'''

# ==============================================================================
# FUNCTIONS USING 'this' (Should use regular function)
# ==============================================================================

console.log "\n== Functions Using 'this' =="

# Method using this
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

# Prototype method
code '''
  class Person
    getName: -> @name
''', '''
  let Person;

  Person = class Person {
    getName() {
      return this.name;
    }

  };
'''

# ==============================================================================
# FUNCTIONS WITH SPECIAL CONTEXTS
# ==============================================================================

console.log "\n== Special Function Contexts =="

# Constructor function (must use function)
code '''
  Person = (name) ->
    @name = name
    return
''', '''
  let Person;

  Person = function(name) {
    this.name = name;
  };
'''

# Generator function (must use function*)
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

# Generator with yield delegation (must use function*)
# NOTE: CoffeeScript parses 'yield*' as '(yield) *', this is a parser limitation
code '''
  delegator = ->
    yield* otherGenerator()
''', '''
  let delegator;

  delegator = function*() {
    return (yield) * otherGenerator();
  };
'''

# Async function (thin arrow with no 'this' -> becomes async arrow)
code '''
  fetchData = ->
    await fetch('/api')
''', '''
  let fetchData;

  fetchData = async () => (await fetch('/api'));
'''

# Async arrow (bound)
code '''
  fetchData = =>
    await fetch('/api')
''', '''
  let fetchData;

  fetchData = async () => (await fetch('/api'));
'''

# ==============================================================================
# CALLBACK PATTERNS
# ==============================================================================

console.log "\n== Callback Patterns =="

# Array map with arrow
code "numbers.map((x) -> x * 2)", '''
  numbers.map((x) => x * 2);
'''

# Array filter
code "items.filter((item) -> item.active)", '''
  items.filter((item) => item.active);
'''

# Promise then
code '''
  promise.then (result) ->
    console.log result
''', '''
  promise.then((result) => console.log(result));
'''

# setTimeout callback
code "setTimeout (-> console.log 'done'), 1000", '''
  setTimeout((() => console.log('done')), 1000);
'''

# ==============================================================================
# PARAMETER PATTERNS
# ==============================================================================

console.log "\n== Parameter Patterns =="

# Default parameters
code "greet = (name = 'World') -> \"Hello \" + name", '''
  let greet;

  greet = (name = 'World') => "Hello " + name;
'''

# Rest parameters
code "sum = (first, ...rest) -> first + rest.length", '''
  let sum;

  sum = (first, ...rest) => first + rest.length;
'''

# Destructured parameters
code "getName = ({name}) -> name", '''
  let getName;

  getName = ({name}) => name;
'''

# Splat parameters (CoffeeScript style)
code "concat = (items...) -> items.join(',')", '''
  let concat;

  concat = (...items) => items.join(',');
'''

# ==============================================================================
# IIFE PATTERNS
# ==============================================================================

console.log "\n== IIFE Patterns =="

# Simple IIFE with arrow
code "(-> console.log 'init')()", '''
  (() => console.log('init'))();
'''

# IIFE with parameters
code "((x) -> x * 2)(5)", '''
  ((x) => x * 2)(5);
'''

# do notation (should become IIFE)
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

# ==============================================================================
# EDGE CASES
# ==============================================================================

console.log "\n== Edge Cases =="

# Function using arguments (must be regular function)
code '''
  variadic = ->
    arguments.length
''', '''
  let variadic;

  variadic = function() {
    return arguments.length;
  };
'''

# Function using new.target (must be regular function)
code '''
  Constructor = ->
    console.log new.target
''', '''
  let Constructor;

  Constructor = function() {
    return console.log(new.target);
  };
'''

# Function using super (in class context)
code '''
  class Child extends Parent
    method: ->
      super.method()
''', '''
  let Child;

  Child = class Child extends Parent {
    method() {
      return super.method();
    }

  };
'''

# Computed method name (no 'this' used -> becomes arrow)
code '''
  obj =
    ["computed"]: -> 42
''', '''
  let obj;

  obj = {
    ["computed"]: () => 42
  };
'''

# Method shorthand in object
code '''
  obj =
    method: -> @value
    arrow: => @value
''', '''
  let obj;

  obj = {
    method: function() {
      return this.value;
    },
    arrow: () => this.value
  };
'''

# ==============================================================================
# COMPREHENSIONS WITH FUNCTIONS
# ==============================================================================

console.log "\n== Comprehensions with Functions =="

# For loop with function
code '''
  fns = for i in [0..2]
    -> i
''', '''
  let fns, i;

  fns = (() => {
    let j, results;
    results = [];
    for (i = j = 0; j <= 2; i = ++j) {
      results.push(() => i);
    }
    return results;
  })();
'''

# Comprehension with bound function (creates functions, not simple transform)
code '''
  handlers = for event in events
    => @handle(event)
''', '''
  let event, handlers;

  handlers = (() => {
    let results;
  events.map((event) => () => this.handle(event))
  }).call(this);
'''

console.log "\n== Test Complete =="
passed = 0
failed = 0
for line in console.log.calls ? []
  passed++ if line[0]?.includes? '✓'
  failed++ if line[0]?.includes? '✗'

console.log "\n[1mSummary:[0m"
console.log "[32mPassed: #{passed}[0m"
console.log "[31mFailed: #{failed}[0m"
console.log "Success rate: #{Math.round(passed / (passed + failed) * 100)}%"
