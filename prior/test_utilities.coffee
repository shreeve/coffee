# Test various CoffeeScript features that use utility functions

# 1. indexOf (in operator)
arr = ['a', 'b', 'c']
if 'b' in arr
  console.log "Found b"

# 2. modulo (%% operator)
result = -7 %% 3
console.log "Modulo result:", result

# 3. slice (splat in parameters)
test = (first, rest...) ->
  console.log "First:", first
  console.log "Rest:", rest

test 1, 2, 3, 4

# 4. bound methods
class MyClass
  constructor: (@name) ->

  greet: =>
    console.log "Hello, #{@name}"

obj = new MyClass("World")
fn = obj.greet
fn()

# 5. hasProp (for own)
obj = {a: 1, b: 2}
for own key of obj
  console.log "Own property:", key, obj[key]
