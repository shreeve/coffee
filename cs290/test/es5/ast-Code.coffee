# Code Solar Directive Tests
# ==========================
# Tests {$ast: 'Code'} directive processing (functions)

test "-> 5", 5
test "=> 10", 10
test "(x) -> x", 42
test "(a, b) -> a + b", 7
test "-> 'hello'", "hello"
test "=> true", true
test "(n) -> n * 2", 20
test "-> null", null
test "(x) => x + 1", 43
test "-> [1, 2, 3]", [1, 2, 3]
test "(s) -> s.toUpperCase()", "HELLO"
test "-> Math.PI", Math.PI
