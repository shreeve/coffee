# Control Flow
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify control flow structures work correctly

# If statements
test "if true then 1 else 2", 1
test "if false then 1 else 2", 2
test "x = 5; if x > 3 then 'yes' else 'no'", "yes"
test "x = 2; if x > 3 then 'yes' else 'no'", "no"

# If without else
test "if true then 42", 42
test "if false then 42", undefined
test "result = if true then 'ok'\nresult", "ok"

# Unless statements
test "unless false then 1 else 2", 1
test "unless true then 1 else 2", 2
test "x = 5; unless x < 3 then 'yes' else 'no'", "yes"

# Ternary-style if
test "if true then 10 else 20", 10
test "x = 5; if x is 5 then 'five' else 'other'", "five"

# Nested if statements
test """
  x = 10
  if x > 5
    if x > 8
      'big'
    else
      'medium'
  else
    'small'
""", "big"

# Switch statements
test """
  x = 2
  switch x
    when 1 then 'one'
    when 2 then 'two'
    when 3 then 'three'
    else 'other'
""", "two"

# Switch with multiple values
test """
  x = 'b'
  switch x
    when 'a', 'b', 'c' then 'letter'
    when 1, 2, 3 then 'number'
    else 'other'
""", "letter"

# Switch without else
test """
  x = 5
  switch x
    when 1 then 'one'
    when 2 then 'two'
""", undefined

# Switch with break (implicit in CoffeeScript)
test """
  x = 1
  result = []
  switch x
    when 1
      result.push('one')
    when 2
      result.push('two')
  result.join(',')
""", "one"

# For loops with arrays
test "(i for i in [1, 2, 3]).join(',')", "1,2,3"
test "(i * 2 for i in [1, 2, 3]).join(',')", "2,4,6"
test "(i for i in [1, 2, 3, 4, 5] when i > 2).join(',')", "3,4,5"

# For loops with ranges
test "(i for i in [0..4]).join(',')", "0,1,2,3,4"
test "(i for i in [5...8]).join(',')", "5,6,7"
test "(i for i in [10..10]).join(',')", "10"

# For-of loops (object iteration)
test "obj = {a: 1, b: 2}; (k for k of obj).sort().join(',')", "a,b"
test "obj = {x: 10, y: 20}; (v for k, v of obj).sort().join(',')", "10,20"

# For-in with index
test '("#{i}:#{v}" for v, i in ["a", "b", "c"]).join(",")', "0:a,1:b,2:c"

# While loops
test """
  i = 0
  result = []
  while i < 3
    result.push(i)
    i++
  result.join(',')
""", "0,1,2"

# Until loops (while not)
test """
  i = 0
  result = []
  until i >= 3
    result.push(i)
    i++
  result.join(',')
""", "0,1,2"

# Loop with break
test """
  result = []
  for i in [1, 2, 3, 4, 5]
    break if i is 3
    result.push(i)
  result.join(',')
""", "1,2"

# Loop with continue
test """
  result = []
  for i in [1, 2, 3, 4, 5]
    continue if i is 3
    result.push(i)
  result.join(',')
""", "1,2,4,5"

# Do-while pattern
test """
  i = 0
  result = []
  loop
    result.push(i)
    i++
    break unless i < 3
  result.join(',')
""", "0,1,2"

# Postfix if
test "x = 5; y = 10 if x is 5; y", 10
test "x = 3; y = 10 if x is 5; y", undefined
test "result = []; result.push(1) if true; result.length", 1

# Postfix unless
test "x = 5; y = 10 unless x is 3; y", 10
test "x = 5; y = 10 unless x is 5; y", undefined

# Postfix for
test "result = []; result.push(i) for i in [1, 2, 3]; result.join(',')", "1,2,3"
test "sum = 0; sum += i for i in [1, 2, 3, 4]; sum", 10

# Guard clauses in comprehensions
test "(i for i in [1, 2, 3, 4, 5] when i % 2 is 0).join(',')", "2,4"
test "(i for i in [1..10] when i > 5).length", 5

# Nested loops
test """
  result = []
  for i in [1, 2]
    for j in [10, 20]
      result.push(i + j)
  result.join(',')
""", "11,21,12,22"

# Try-catch-finally
test """
  try
    'success'
  catch e
    'error'
""", "success"

test """
  try
    throw new Error('test')
    'success'
  catch e
    'caught'
""", "caught"

test """
  result = []
  try
    result.push(1)
  catch e
    result.push(2)
  finally
    result.push(3)
  result.join(',')
""", "1,3"

# Return statements
test "f = -> return 5; 10\nf()", 5
test "f = -> x = 5; return x * 2\nf()", 10
test "f = (x) -> return if x < 0; x * 2\nf(5)", 10
test "f = (x) -> return if x < 0; x * 2\nf(-5)", undefined

# Implicit returns
test "f = -> 42\nf()", 42
test "f = -> x = 5; x * 2\nf()", 10
test "f = (x) -> if x > 0 then x else -x\nf(-5)", 5

# Early returns with conditions
test """
  process = (x) ->
    return 0 if x is 0
    return -1 if x < 0
    x * 2
  process(5)
""", 10

# Chained comparisons
test "x = 5; 1 < x < 10", true
test "x = 15; 1 < x < 10", false
test "3 <= 3 <= 3", true

# Boolean logic short-circuiting
test "true or 'not evaluated'", true
test "false or 'evaluated'", "evaluated"
test "true and 'evaluated'", "evaluated"
test "false and 'not evaluated'", false

# Existential operator
test "x = 5; x?", true
test "x = null; x?", false
test "x = undefined; x?", false
test "x = 0; x?", true
