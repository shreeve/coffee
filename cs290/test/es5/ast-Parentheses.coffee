# Parentheses Solar Directive Tests
# ==================================
# Tests {$ast: 'Parens'} directive processing  

test "(5)", 5
test "(1 + 2)", 3
test "((3))", 3
test "(x = 10)", 10
test "('hello')", "hello"
test "(true)", true
