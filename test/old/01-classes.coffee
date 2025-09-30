# Classes
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify class features work correctly

# Basic class definition and instantiation
test "class A then constructor: -> @x = 1\n(new A).x", 1
test "class B then method: -> 'hello'\n(new B).method()", 'hello'

# Class with constructor parameters
test "class C then constructor: (@name) ->\n(new C('test')).name", 'test'
test "class D then constructor: (a, @b) -> @a = a\nd = new D(1, 2)\nd.a + d.b", 3

# Static methods
test "class E then @staticMethod: -> 'static'\nE.staticMethod()", 'static'
test "class F then @value: 42\nF.value", 42

# Instance methods
test "class G then method: -> @value = 10\ng = new G\ng.method()\ng.value", 10
test "class H then greet: (name) -> 'Hello ' + name\n(new H).greet('World')", 'Hello World'

# Inheritance with extends
test "class Base then method: -> 'base'\nclass Child extends Base\n(new Child).method()", 'base'
test "class A then x: 1\nclass B extends A then y: 2\nb = new B\nb.x + b.y", 3

# Super calls in methods
test """
  class Parent
    method: -> 'parent'
  class Child extends Parent
    method: -> super() + '-child'
  (new Child).method()
""", 'parent-child'

# Super in constructor
test """
  class Base
    constructor: (@value) ->
  class Extended extends Base
    constructor: (value) ->
      super(value * 2)
  (new Extended(5)).value
""", 10

class Button
  constructor: (@label) ->
  click: =>
    @label
btn = new Button('OK')
click = btn.click
x = click()
test "'OK'", x

# Class expressions
test "C = class then method: -> 'expr'\n(new C).method()", 'expr'

# Anonymous classes
test "(new class then constructor: -> @x = 7).x", 7
test "typeof class", "function"

# Constructor with default parameters
test "class A then constructor: (@x = 5) ->\n(new A).x", 5
test "class B then constructor: (@x = 10) ->\n(new B(20)).x", 20

# Multiple inheritance levels
test """
  class Level1
    value: -> 1
  class Level2 extends Level1
    value: -> super() + 1
  class Level3 extends Level2
    value: -> super() + 1
  (new Level3).value()
""", 3

# Static inheritance
test """
  class Base
    @staticProp: 'base'
  class Child extends Base
  Child.staticProp
""", 'base'

# Property initialization in class body
test "class A then prop: 'initialized'\n(new A).prop", 'initialized'
test "class B then x: 1; y: 2\nb = new B\nb.x + b.y", 3

# Methods with arguments
test """
  class Calculator
    add: (a, b) -> a + b
    multiply: (a, b) -> a * b
  calc = new Calculator
  calc.add(2, 3) + calc.multiply(4, 5)
""", 25

# This binding in methods
test """
  class Container
    constructor: -> @items = []
    add: (item) -> @items.push(item); @
    count: -> @items.length
  c = new Container
  c.add(1).add(2).add(3).count()
""", 3

# Computed property names
test '''
  name = 'dynamic'
  class A
    "#{name}Method": -> 'computed'
  (new A).dynamicMethod()
''', 'computed'

# Class with both static and instance methods
test """
  class Utils
    @classMethod: -> 'class'
    instanceMethod: -> 'instance'
  Utils.classMethod() + '-' + (new Utils).instanceMethod()
""", 'class-instance'

# Constructor returns different object
test """
  class Special
    constructor: -> return {custom: true}
  (new Special).custom
""", true

# Class prototype access
test "class A then method: ->\ntypeof A.prototype.method", "function"
test "class B then method: -> 'proto'\nB::method.call({})", 'proto'

# Executable class body
test """
  value = 10
  class A
    if value > 5
      method: -> 'big'
    else
      method: -> 'small'
  (new A).method()
""", 'big'

# Nested classes
test """
  class Outer
    constructor: -> @name = 'outer'
    class @Inner
      constructor: -> @name = 'inner'
  (new Outer.Inner).name
""", 'inner'

# Super without extends throws (should not compile, skip this)
# test "class A then constructor: -> super()", "should throw"

# Methods calling other methods
test """
  class Chain
    first: -> @second()
    second: -> @third()
    third: -> 'end'
  (new Chain).first()
""", 'end'

# Constructor with rest parameters
test """
  class Collector
    constructor: (first, @rest...) ->
      @first = first
  c = new Collector(1, 2, 3, 4)
  c.first + c.rest.length
""", 4

# Class with getter-like methods
test """
  class Person
    constructor: (@firstName, @lastName) ->
    fullName: -> @firstName + ' ' + @lastName
  (new Person('John', 'Doe')).fullName()
""", 'John Doe'

# Conditional super calls
test """
  class Base
    method: (x) -> x * 2
  class Child extends Base
    method: (x) ->
      if x > 10 then super(x) else x
  c = new Child
  c.method(5) + c.method(20)
""", 45
