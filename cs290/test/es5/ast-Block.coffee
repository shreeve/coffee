# Block Solar Directive Tests
# ===========================
# Tests {$ast: 'Block'} directive processing

test "x = 1; y = 2; x + y", 3
test "a = 5; b = 10; a * b", 50  
test "name = 'test'; name", "test"
test "value = true; value", true
test "result = 42; result + 1", 43
test "temp = 'hello'; temp + ' world'", "hello world"
