# While Solar Directive Tests
# ===========================
# Tests {$ast: 'While'} directive processing

test "while false then break", undefined
test "until true then break", undefined  
test "x = 0; while x < 3 then x++", 3
test "i = 5; until i <= 0 then i--", 0
test "while true then break", undefined
test "until false then break", undefined
