# Code Solar Directive Tests
# ==========================
# Tests {$ast: 'Code'} directive processing (functions)

test "(-> 5)()", 5
test "(=> 10)()", 10
test "((x) -> x)(42)", 42
test "((a, b) -> a + b)(3, 4)", 7
test "(-> 'hello')()", "hello"
test "(=> true)()", true
test "((n) -> n * 2)(10)", 20
test "(-> null)()", null
test "((x) => x + 1)(42)", 43
test "(-> [1, 2, 3])()", [1, 2, 3]
test "((s) -> s.toUpperCase())('hello')", "HELLO"
test "(-> Math.PI)()", Math.PI
