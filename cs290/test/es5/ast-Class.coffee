# Class Solar Directive Tests
# ===========================
# Tests {$ast: 'Class'} directive processing

test "class A", undefined
test "class B extends A", undefined
test "class C then constructor: -> @x = 1", undefined
test "class D extends Object", undefined
test "class E then method: -> 5", undefined
test "class F then @static: 10", undefined
