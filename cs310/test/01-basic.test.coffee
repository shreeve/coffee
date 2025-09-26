# Basic Solar Directive Tests
# ===========================

test "program with single number literal", ->
  # Test minimal program: just "7"
  # Should compile to JavaScript that evaluates to 7
  result = CoffeeScript.compile('7')
  ok result.length > 0, "Should generate JavaScript code"

  # Evaluate the compiled JavaScript
  value = eval(result)
  eq value, 7, "Compiled program should evaluate to 7"
