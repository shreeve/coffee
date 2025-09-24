# Property Access Solar Directive Tests
# ======================================
# Tests property access and method calls

test "obj.prop", "value"
test "obj.method()", "result"
test "obj.nested.deep", "found"
test "obj['key']", "dynamic"
test "obj?prop", "safe"
test "obj?.method?()", "conditional"
test "arr[0]", "first"
test "arr[arr.length - 1]", "last"
test "Math.PI", Math.PI
test "Math.abs(-5)", 5
test "String.fromCharCode(65)", "A"
test "Number.parseInt('42')", 42
test "Array.from([1, 2])", [1, 2]
test "Object.keys({a: 1})", ['a']
test "Date.now()", 1234567890
test "JSON.stringify({x: 1})", '{"x":1}'
test "console.log('test')", undefined
test "process.env.NODE_ENV", undefined
