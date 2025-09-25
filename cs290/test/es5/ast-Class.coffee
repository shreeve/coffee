# Class Solar Directive Tests
# ===========================
# Tests {$ast: 'Class'} directive processing

test "class A", class A
test "class B extends A", class B extends Object
test "class C then constructor: -> @x = 1", class C then constructor: -> @x = 1
test "class D extends Object", class D extends Object
test "class E then method: -> 5", class E then method: -> 5
test "class F then @static: 10", class F then @static: 10
