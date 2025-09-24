# Slicing Solar Directive Tests
# ==============================
# Tests array/string slicing operations

test "[1, 2, 3, 4, 5][1..3]", [2, 3, 4]
test "[1, 2, 3, 4, 5][2...]", [3, 4, 5]
test "[1, 2, 3, 4, 5][...2]", [1, 2]
test "'hello'[1..3]", "ell"
test "'world'[2...]", "rld"
test "'test'[...2]", "te"
test "[10, 20, 30, 40][0..1]", [10, 20]
test "'coffee'[0..2]", "cof"
