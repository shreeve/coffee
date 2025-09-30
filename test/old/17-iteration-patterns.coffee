# Advanced Iteration Patterns
# ===========================
# Tests for various iteration patterns including for-from loops

# For-from loops
test "(x for x from [1, 2, 3]).join(',')", "1,2,3"
test "(x * 2 for x from [1, 2, 3]).join(',')", "2,4,6"
test "(x for x from [1, 2, 3] when x > 1).join(',')", "2,3"

# Loop variable accessibility after for-from
test "d = (x for x from [1, 2]); x", 2

# Own properties iteration
test """
  parent = {inherited: 'parent'}
  child = Object.create(parent)
  child.own = 'child'
  results = []
  for own key of child
    results.push(key)
  results.join(',')
""", "own"

# Multiple iteration variables (destructuring in loops)
test """
  pairs = [[1, 2], [3, 4], [5, 6]]
  sums = []
  for [a, b] in pairs
    sums.push(a + b)
  sums.join(',')
""", "3,7,11"

test """
  items = [{x: 1, y: 2}, {x: 3, y: 4}]
  sums = []
  for {x, y} in items
    sums.push(x + y)
  sums.join(',')
""", "3,7"

# While with assignment
test """
  values = [1, 2, 3]
  sum = 0
  while val = values.shift()
    sum += val
  sum
""", 6

# Until with condition
test """
  i = 0
  results = []
  until i >= 3
    results.push(i++)
  results.join(',')
""", "0,1,2"

# Loop with guard
test """
  i = 0
  result = loop
    i++
    break i if i > 5
  result
""", 6

# For-in with step and guard
test "(i for i in [0..10] by 2 when i % 4 is 0).join(',')", "0,4,8"

# Nested iterations with guards
test """
  result = []
  for i in [1..3]
    for j in [1..3]
      result.push(i * j) if i isnt j
  result.join(',')
""", "2,3,3,6,2,6"

# Range iteration with variables
test """
  start = 1
  end = 5
  (i for i in [start..end]).join(',')
""", "1,2,3,4,5"

# Postfix iteration with multiple statements
test """
  results = []
  for x in [1, 2, 3]
    y = x * 2
    results.push(y)
  results.join(',')
""", "2,4,6"

# Iteration with continue
test """
  results = []
  for i in [1..5]
    continue if i % 2 is 0
    results.push(i)
  results.join(',')
""", "1,3,5"

# Iteration with early return in function
test """
  findFirst = (arr, condition) ->
    for item in arr
      return item if condition(item)
    null
  findFirst([1, 2, 3, 4], (x) -> x > 2)
""", 3

# Do notation in comprehensions
test "(do (x) -> x * x for x in [1, 2, 3]).join(',')", "1,4,9"

# By clause with negative step
test "(i for i in [10..1] by -2).join(',')", "10,8,6,4,2"
