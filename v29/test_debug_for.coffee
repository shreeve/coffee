# Simple test to debug For loop implicit returns
testFunc = ->
  console.log "Starting"
  for x in [1, 2, 3]
    x * 2

result = testFunc()
console.log "Result:", result
