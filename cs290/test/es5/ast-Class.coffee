# Class Solar Directive Tests
# ===========================
# Tests {$ast: 'Class'} directive processing

test "class A", ->
  result = eval("class A { }; A")
  typeof result is 'function' and result.name is 'A'
test "class B extends A", ->
  eval("class A { }; class B extends A { }; B") instanceof Function
test "class C then constructor: -> @x = 1", ->
  eval("class C { constructor() { this.x = 1; } }; C") instanceof Function
test "class D extends Object", ->
  eval("class D extends Object { }; D") instanceof Function
test "class E then method: -> 5", ->
  eval("class E { method() { return 5; } }; E") instanceof Function
test "class F then @static: 10", ->
  eval("class F { static static = 10; }; F") instanceof Function
