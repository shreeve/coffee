# Test function with assignment in condition
test = ->
  return 0 unless match = /test/.exec("test")
  console.log match

  # Also test destructuring
  [a, b] = [1, 2]
  console.log a, b

test()
