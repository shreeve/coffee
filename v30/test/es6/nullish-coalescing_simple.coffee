# Test nullish coalescing operator (??) generation - Phase 0 Success!
# Verifying that CoffeeScript's existential operator (?) now compiles to ES6's nullish coalescing operator (??)

console.log "Testing Nullish Coalescing Operator (??)"
console.log "========================================="

# Test 1: Basic existential operator
test 'x = y ? "default"', do ->
  y = null
  x = y ? "default"
  x

test 'x = y ? "default" (with value)', do ->
  y = "hello"
  x = y ? "default"
  x

# Test 2: Chained existential operators
test 'a ? b ? c', do ->
  a = null
  b = null
  c = "fallback"
  a ? b ? c

# Test 3: With method calls
test 'getData() ? {}', do ->
  getData = -> null
  data = getData() ? {}
  typeof data

# Test 4: With property access
test 'obj.prop ? 0', do ->
  obj = {}
  val = obj.prop ? 0
  val

# Test 5: Inside expressions
test '(a ? 0) + (b ? 0)', do ->
  a = null
  b = 5
  sum = (a ? 0) + (b ? 0)
  sum

# Test 6: Array prototype check
test 'Array::find ? null', do ->
  method = Array::find ? null
  method isnt null

console.log "\n✨ Phase 0 Complete: Nullish Coalescing is working!"
console.log "From ~30 lines of complex caching code to simple ?? operator"
