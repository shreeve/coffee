# Arr Solar Directive Tests  
# =========================
# Tests {$ast: 'Arr'} directive processing

test "[]", []
test "[1, 2, 3]", [1, 2, 3]
test "[42]", [42]
test "['hello', 'world']", ['hello', 'world']
test "[1, 'two', true]", [1, 'two', true]
test "[[1, 2], [3, 4]]", [[1, 2], [3, 4]]
