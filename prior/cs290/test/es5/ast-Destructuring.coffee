# Destructuring Solar Directive Tests
# ====================================
# Tests destructuring assignment patterns

test "[a, b] = [1, 2]; a", 1
test "[x, y] = [10, 20]; y", 20
test "{name, value} = {name: 'test', value: 42}; name", "test"
test "{x, y} = {x: 1, y: 2}; x + y", 3
test "[first, ...rest] = [1, 2, 3]; first", 1
test "[head, ...tail] = [10, 20, 30]; tail", [20, 30]
test "{a, b = 5} = {a: 1}; b", 5
test "{x = 10, y = 20} = {}; x", 10
