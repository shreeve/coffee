# JavaScript Literals and Special Features
# ===========================
# Tests for backtick JavaScript literals, eval, and strict mode

# Backtick JavaScript literals
test "`5 + 3`", 8
test "`'hello'.toUpperCase()`", "HELLO"
test "x = 10; `x * 2`", 20
test "`Math.PI`", Math.PI
test "`[1, 2, 3].length`", 3

# Backticks with complex expressions
test "`(function() { return 42; })()`", 42
test "`(() => 99)()`", 99
test "`[1, 2, 3].map(x => x * 2)`", [2, 4, 6]

# Backticks accessing CoffeeScript variables
test "value = 100; `value / 2`", 50
test "obj = {x: 5}; `obj.x * 3`", 15
test "arr = [10, 20]; `arr[0] + arr[1]`", 30

# Multiline backticks
test """`
  var sum = 0;
  for (var i = 1; i <= 3; i++) {
    sum += i;
  }
  sum
`""", 6

# Backticks in expressions
test "result = `10 + 20`; result", 30
test "if `true` then 'yes' else 'no'", "yes"
test "(`5 > 3`) and true", true

# Template literals inside backticks
test "name = 'World'; `\`Hello, ${name}!\``", "Hello, World!"
test "`\`Sum: ${2 + 3}\``", "Sum: 5"

# Eval usage (when available)
test "eval('5 + 3')", 8
test "eval('Math.PI')", Math.PI
test "x = 10; eval('x * 2')", 20

# Global eval
test "globalEval = eval; globalEval('1 + 1')", 2

# Indirect eval (should be global)
test "(0, eval)('this')", this

# Strict mode directives
test "'use strict'; true", true
test '"use strict"; true', true

# Strict mode in functions
test """
  f = ->
    'use strict'
    true
  f()
""", true

# Strict mode with backticks
test """`
  'use strict';
  true
`""", true

# JavaScript reserved words as properties
test "obj = {class: 'value'}; obj.class", "value"
test "obj = {function: 'func'}; obj.function", "func"
test "obj = {var: 'variable'}; obj.var", "variable"

# JavaScript this binding in backticks
test """
  obj = {
    value: 42
    method: -> `this.value`
  }
  obj.method()
""", 42

# JavaScript typeof in backticks
test "`typeof 5`", "number"
test "`typeof 'string'`", "string"
test "`typeof {}`", "object"
test "`typeof []`", "object"
test "`typeof null`", "object"
test "`typeof undefined`", "undefined"

# JavaScript instanceof in backticks
test "`[] instanceof Array`", true
test "`{} instanceof Object`", true
test "`new Date() instanceof Date`", true

# JavaScript operators in backticks
test "`5 === 5`", true
test "`5 == '5'`", true
test "`null == undefined`", true
test "`null === undefined`", false
test "`5 !== '5'`", true

# Void operator
test "`void 0`", undefined
test "`void(42)`", undefined
test "`void 'test'`", undefined

# Delete operator in backticks
test "obj = {x: 1}; `delete obj.x`; obj.x", undefined

# In operator in backticks
test "obj = {x: 1}; `'x' in obj`", true
test "obj = {x: 1}; `'y' in obj`", false

# JavaScript array methods in backticks
test "`[1, 2, 3].includes(2)`", true
test "`[1, 2, 3].find(x => x > 1)`", 2
test "`[1, 2, 3].findIndex(x => x > 1)`", 1

# JavaScript spread in backticks
test "`[...[1, 2, 3]]`", [1, 2, 3]
test "`{...{a: 1, b: 2}}`", {a: 1, b: 2}

# JavaScript destructuring in backticks
test """`
  const [a, b] = [1, 2];
  a + b
`""", 3

test """`
  const {x, y} = {x: 10, y: 20};
  x + y
`""", 30

# Mixed CoffeeScript and JavaScript
test "cs = 5; js = `cs * 2`; cs + js", 15
test "arr = [1, 2, 3]; `arr.reduce((a, b) => a + b, 0)`", 6

# Edge cases
test "`null`", null
test "`undefined`", undefined
test "`NaN`", NaN
test "`Infinity`", Infinity
test "`-Infinity`", -Infinity

# Compilation output tests  
code "`console.log(1)`", "console.log(1);"
code "```js\n1 + 1\n```", "1 + 1;"
