# Test all three improvements:
# 1. Helper utilities without numbering
# 2. Try/catch variable promotion
# 3. Two-pass Solar directive approach

# Test 1: Improved helper utilities
testHelpers = ->
  # Test native includes() instead of indexOf
  items = ['apple', 'banana', 'cherry']
  if 'banana' in items
    console.log "Found banana using ES6 includes()"

  # Test modulo (should declare once as const)
  result = -7 %% 3
  console.log "Modulo result:", result

# Test 2: Try/catch variable promotion
testTryCatch = ->
  # Variables declared in try but used in catch/finally
  try
    data = JSON.parse('{"value": 42}')
    result = data.value * 2
    status = "success"
  catch err
    console.log "Error:", err
    data = null      # These should work because variables are promoted
    result = 0
    status = "error"
  finally
    console.log "Final data:", data
    console.log "Final result:", result
    console.log "Final status:", status

# Test 3: Comprehensive scoping
testScoping = ->
  # Test const for single assignment
  message = "Hello"

  # Test let for reassigned variables
  counter = 0
  counter = counter + 1

  # Test loop variable scoping
  results = []
  for item in ['a', 'b', 'c']
    results.push item.toUpperCase()

  # Test nested scopes
  if counter > 0
    nested = "inside if"
    console.log nested

  console.log "Message:", message
  console.log "Counter:", counter
  console.log "Results:", results

# Run all tests
console.log "=== Test 1: Helper Utilities ==="
testHelpers()

console.log "\n=== Test 2: Try/Catch Promotion ==="
testTryCatch()

console.log "\n=== Test 3: Comprehensive Scoping ==="
testScoping()
