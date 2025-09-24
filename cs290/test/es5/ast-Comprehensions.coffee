# Comprehensions Solar Directive Tests
# =====================================
# Tests array/object comprehensions

test "(x for x in [1, 2, 3])", [1, 2, 3]
test "(x * 2 for x in [1, 2, 3])", [2, 4, 6]
test "(x for x in [1..5] when x % 2 == 0)", [2, 4]
test "(x + 1 for x in [0, 1, 2])", [1, 2, 3]  
test "(item for item in ['a', 'b', 'c'])", ['a', 'b', 'c']
test "(n for n in [1, 2, 3, 4, 5] when n > 3)", [4, 5]
test "(val * val for val in [1, 2, 3])", [1, 4, 9]
test "(s.toUpperCase() for s in ['a', 'b'])", ['A', 'B']
