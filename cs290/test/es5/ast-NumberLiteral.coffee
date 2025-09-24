# NumberLiteral Solar Directive Tests
# ===================================
# Tests {$ast: 'NumberLiteral'} directive processing

test "NumberLiteral directive - basic integer", ->
  # Test minimal number literal
  result = CoffeeScript.compile('7')
  value = eval(result)
  eq value, 7, "Should compile '7' to JavaScript number 7"

test "NumberLiteral directive - negative number", ->
  result = CoffeeScript.compile('-42')
  value = eval(result)
  eq value, -42, "Should handle negative numbers"

test "NumberLiteral directive - decimal", ->
  result = CoffeeScript.compile('3.14')
  value = eval(result)
  eq value, 3.14, "Should handle decimal numbers"

test "NumberLiteral directive - binary literal", ->
  result = CoffeeScript.compile('0b1010')
  value = eval(result)
  eq value, 10, "Should handle binary literals"

test "NumberLiteral directive - hex literal", ->
  result = CoffeeScript.compile('0xFF')
  value = eval(result)
  eq value, 255, "Should handle hex literals"

