# Existence Solar Directive Tests  
# ================================
# Tests {$ast: 'Existence'} directive processing

test "x?", false
test "null?", false  
test "undefined?", false
test "42?", true
test "'hello'?", true
test "Math?", true
