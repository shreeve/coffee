# Class Solar Directive Tests
# ===========================
# Tests {$ast: 'Class'} directive processing

test "typeof class A", "function"
test "typeof class B extends Object", "function"
test "(new (class C then constructor: -> @x = 1)).x", 1
test "typeof class D extends Object", "function"
test "(new (class E then method: -> 5)).method()", 5
test "(class F then @static: 10).static", 10
