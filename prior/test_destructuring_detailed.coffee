# Test various destructuring patterns

# Simple array destructuring
test1 = ->
  [a, b, c] = [1, 2, 3]
  console.log a, b, c

# Nested destructuring
test2 = ->
  [x, [y, z]] = [1, [2, 3]]
  console.log x, y, z

# Object destructuring
test3 = ->
  {name, age} = {name: 'Bob', age: 30}
  console.log name, age

# Mixed with existing variables
test4 = ->
  existing = {}
  [existing.a, existing.b, newVar] = [1, 2, 3]
  console.log newVar

test1()
test2()
test3()
test4()
