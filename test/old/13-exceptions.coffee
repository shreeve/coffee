# Exception Handling
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify try/catch/finally work correctly

# Basic try-catch
test """
  try
    'success'
  catch e
    'error'
""", "success"

test """
  try
    throw new Error('test')
    'should not reach'
  catch e
    'caught'
""", "caught"

# Try-catch-finally
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

test """
  result = []
  try
    result.push(1)
    throw new Error('test')
  catch e
    result.push(2)
  finally
    result.push(3)
  result.join(',')
""", "1,2,3"

# Finally always executes
test """
  result = []
  f = ->
    try
      result.push(1)
      return 'early'
    finally
      result.push(2)
  value = f()
  result.join(',') + ':' + value
""", "1,2:early"

# Catching specific error properties
test """
  try
    throw new Error('custom message')
  catch e
    e.message
""", "custom message"

test """
  try
    error = new Error()
    error.code = 404
    throw error
  catch e
    e.code
""", 404

# Nested try-catch
test """
  try
    try
      throw new Error('inner')
    catch e
      throw new Error('rethrow')
  catch e
    e.message
""", "rethrow"

# Try without catch (only finally)
test """
  result = 'initial'
  executed = false
  try
    try
      result = 'changed'
      throw new Error()
    finally
      executed = true
  catch e
    # outer catch
  result + ':' + executed
""", "changed:true"

# Error types
test """
  try
    throw new TypeError('type error')
  catch e
    e instanceof TypeError
""", true

test """
  try
    throw new RangeError('range error')
  catch e
    e.name
""", "RangeError"

# Custom errors
test """
  class CustomError extends Error
    constructor: (@code) ->
      super('custom')

  try
    throw new CustomError(42)
  catch e
    e.code
""", 42

# Try-catch with return values
test """
  getValue = ->
    try
      return 10
    catch e
      return 20
  getValue()
""", 10

test """
  getValue = ->
    try
      throw new Error()
      return 10
    catch e
      return 20
  getValue()
""", 20

# Try-catch in expressions
test """
  result = try
    'success'
  catch e
    'failure'
  result
""", "success"

test """
  result = try
    throw new Error()
    'success'
  catch e
    'failure'
  result
""", "failure"

# Throwing various types
test """
  try
    throw 'string error'
  catch e
    e
""", "string error"

test """
  try
    throw 42
  catch e
    e
""", 42

test """
  try
    throw {error: true, message: 'object throw'}
  catch e
    e.message
""", "object throw"

# Re-throwing errors
test """
  try
    try
      throw new Error('original')
    catch e
      e.modified = true
      throw e
  catch e
    e.message + ':' + e.modified
""", "original:true"

# Multiple catch scenarios
test """
  attempts = 0
  tryDivide = (a, b) ->
    attempts++
    try
      throw new Error('zero division') if b is 0
      a / b
    catch e
      null

  result = tryDivide(10, 0) ? tryDivide(10, 2)
  result
""", 5

# Error in finally
test """
  result = []
  try
    try
      result.push(1)
    finally
      result.push(2)
      throw new Error('finally error')
  catch e
    result.push(3)
  result.join(',')
""", "1,2,3"

# Try-catch with destructuring
test """
  try
    obj = null
    {x, y} = obj
  catch e
    'caught'
""", "caught"

# Guard patterns with try-catch
test """
  safeDivide = (a, b) ->
    try
      throw new Error() if b is 0
      a / b
    catch
      Infinity
  safeDivide(10, 0)
""", Infinity

# Stack preservation
test """
  try
    throw new Error('test')
  catch e
    typeof e.stack
""", "string"

# Compilation output tests
code "throw new Error('test')", "throw new Error('test');"
code "try x catch e then y", "var e;\n\ntry {\n  x;\n} catch (error) {\n  e = error;\n  y;\n}"

# Invalid syntax tests  
fail "catch without try"  # catch must follow try
