# Test if exported functions have implicit returns
export testFunc = ->
  for x in [1, 2, 3]
    x * 2

# Regular function for comparison
regularFunc = ->
  for x in [1, 2, 3]
    x * 2
