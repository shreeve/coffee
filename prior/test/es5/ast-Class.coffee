# Class Solar Directive Tests
# ===========================
# Tests {$ast: 'Class'} directive processing

test "typeof class A", "function"
test "typeof class B extends Object", "function"
test "(new (class C then constructor: -> @x = 1)).x", 1
test "typeof class D extends Object", "function"
test "(new (class E then method: -> 5)).method()", 5
# Static property compilation bug - still not fixed
# The issue is deep in how ClassProperty/ClassPrototypeProperty are handled
# @static: 10 compiles to F.prototype[F] = 10 instead of F.static = 10
test "(class F then @static: 10).static", 10

# Constructor @param tests
test "(new (class then constructor: (@x) ->)(5)).x", 5
test "(new (class then constructor: (@x = 10) ->)()).x", 10
test "(new (class then constructor: (@x = 10) ->)(20)).x", 20
test "class G then constructor: (@a, @b = 5) ->\ng = new G(1)\ng.a + g.b", 6
test "class H then constructor: (@a = 2, @b = 3) ->\nh = new H()\nh.a * h.b", 6
