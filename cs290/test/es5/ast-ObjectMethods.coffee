# Object Methods Solar Directive Tests  
# =====================================
# Tests object method calls and properties

test "Object.keys({a: 1, b: 2})", ['a', 'b']
test "Object.values({x: 10, y: 20})", [10, 20]
test "Object.entries({name: 'test'})", [['name', 'test']]
test "Object.assign({}, {a: 1})", {a: 1}
test "Object.create(null)", {}
test "Object.freeze({x: 1})", {x: 1}
test "Object.seal({y: 2})", {y: 2}
test "{a: 1}.hasOwnProperty('a')", true
test "{b: 2}.hasOwnProperty('c')", false
test "{}.constructor", Object
test "{x: 1}.toString()", "[object Object]"
test "{}.valueOf()", {}
test "Object.getPrototypeOf({})", Object.prototype
test "Object.getOwnPropertyNames({a: 1})", ['a']
test "Object.defineProperty({}, 'x', {value: 5})", {x: 5}
test "Object.is(1, 1)", true
test "Object.is(1, 2)", false
