# Property Access Solar Directive Tests
# ======================================
# Tests property access and method calls

test 'obj = Object.create(null); obj.prop = "value"; obj.prop', "value"
test 'obj = Object.create(null); obj.method = () => "result"; obj.method()', "result"
test 'obj = Object.create(null); obj.nested = {deep: "found"}; obj.nested.deep', "found"
test 'obj = Object.create(null); obj["key"] = "dynamic"; obj["key"]', "dynamic"
test 'obj = Object.create(null); obj.prop = "safe"; obj?.prop', "safe"
test 'obj = Object.create(null); obj.method = () => "conditional"; obj?.method?.()', "conditional"
test 'arr = ["first", "middle", "last"]; arr[0]', "first"
test 'arr = ["first", "middle", "last"]; arr[arr.length - 1]', "last"
test "Math.PI", Math.PI
test "Math.abs(-5)", 5
test "String.fromCharCode(65)", "A"
test "Number.parseInt('42')", 42
test "Array.from([1, 2])", [1, 2]
test "Object.keys({a: 1})", ['a']
test "Date.now()", ->
  result = Date.now()
  typeof result is 'number' and result > 0
test "JSON.stringify({x: 1})", '{"x":1}'
test "console.log('test')", undefined
test "process.env.NODE_ENV", undefined

# Additional method call and optional-call coverage
test 'obj = Object.create(null); obj.method = (x, y) => x + y; obj.method(1, 2)', 3
test 'obj = Object.create(null); obj.method = (x) => x; obj?.method?(5)', 5
test 'a = Object.create(null); a.b = {c: -> {d: 42}}; a?.b.c?().d', 42
