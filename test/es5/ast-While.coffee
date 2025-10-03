# While Solar Directive Tests
# ===========================
# Tests {$ast: 'While'} directive processing
# Note: These test natural CoffeeScript behavior (last value returned)

# Tests that return undefined (loops that don't execute or have break)
test "while false then break", undefined
test "until true then break", undefined
test "while true then break", undefined
test "until false then break", undefined

# Tests that return the last iteration value
# Post-increment operators now work correctly!
test "x = 0; while x < 3 then x++", 2
test "i = 5; until i <= 0 then i--", 1

# Tests with false/true conditions (loops that don't execute) - checking final variable value
test "x = 0; y = (while false then x++); x", 0
test "x = 0; y = (until true then x++); x", 0

# Tests with loop execution - checking final variable value
test "x = 0; (while x < 3 then x++); x", 3
test "i = 5; (until i <= 0 then i--); i", 0

# Tests with simple loops - when assigned, loops return arrays
test "x = 0; y = while x < 2 then x += 1", [1, 2]
test "x = 10; y = until x < 5 then x -= 2", [8, 6, 4]
