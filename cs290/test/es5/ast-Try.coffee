# Try Solar Directive Tests
# =========================
# Tests {$ast: 'Try'} directive processing

test "try 5", 5

# Try/catch with 'then' syntax - now fixed!
test "try 'hello' catch e then 'error'", "hello"
test "try throw 'oops' catch e then 'caught'", "caught"
test "try null catch e then 'null'", null

test "try 42 finally console.log('done')", 42
test "try true finally false", true
