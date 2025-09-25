# While Solar Directive Tests
# ===========================
# Tests {$ast: 'While'} directive processing

# Tests that return empty arrays (loops that don't execute or have break)
test "while false then break", []
test "until true then break", []
test "while true then break", []
test "until false then break", []

# Tests that return arrays of iteration values
# Post-increment operators now work correctly!
test "x = 0; while x < 3 then x++", [0, 1, 2]
test "i = 5; until i <= 0 then i--", [5, 4, 3, 2, 1]

# Tests with false/true conditions (loops that don't execute) - checking final variable value
test "x = 0; y = (while false then x++); x", 0
test "x = 0; y = (until true then x++); x", 0

# Tests with loop execution - checking final variable value
test "x = 0; (while x < 3 then x++); x", 3
test "i = 5; (until i <= 0 then i--); i", 0

# Tests with simple loops - checking final variable value
test "x = 0; y = while x < 2 then x += 1; x", 2
test "x = 10; y = until x < 5 then x -= 2; x", 4
