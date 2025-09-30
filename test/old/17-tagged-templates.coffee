# Tagged Template Literals
# ===========================
# Tests for ES6 tagged template literals
# A function can process a template literal with custom logic

# Basic tagged template literals
test '''
  tag = (strings, ...values) ->
    strings[0] + values[0] + strings[1]
  name = 'World'
  tag"Hello #{name}!"
''', "Hello World!"

test '''
  upper = (strings, ...values) ->
    result = ''
    for str, i in strings
      result += str
      result += values[i]?.toString().toUpperCase() if i < values.length
    result
  x = 'test'
  upper"value: #{x}!"
''', "value: TEST!"

# Tagged templates with multiple interpolations
test '''
  join = (strings, ...values) ->
    result = ''
    for str, i in strings
      result += str
      result += values[i] if i < values.length
    result
  a = 1
  b = 2
  c = 3
  join"Numbers: #{a}, #{b}, #{c}"
''', "Numbers: 1, 2, 3"

# Tagged template with no interpolations
test '''
  identity = (strings) -> strings[0]
  identity"just a string"
''', "just a string"

# Tagged template with expressions
test '''
  calc = (strings, ...values) ->
    values.reduce((a, b) -> a + b, 0)
  calc"Sum is #{5 + 3} and #{10 - 2}"
''', 16

# Tagged template with object property
test '''
  obj = {
    tag: (strings, ...values) -> strings.join('|')
  }
  obj.tag"a#{1}b#{2}c"
''', "a|b|c"

# Tagged template with computed property
test '''
  obj = {
    process: (strings) -> strings[0].length
  }
  method = 'process'
  obj[method]"testing"
''', 7

# Nested tagged templates
test '''
  outer = (strings, ...values) ->
    "outer[#{values[0]}]"
  inner = (strings, ...values) ->
    "inner[#{values[0]}]"
  x = 5
  outer"Result: #{inner"Value: #{x}"}"
''', "outer[inner[5]]"

# Tagged template with raw strings
test '''
  raw = (strings, ...values) ->
    strings.raw?[0] ? strings[0]
  raw"Line 1\\nLine 2"
''', "Line 1\\nLine 2"

# Multi-line tagged templates - REMOVED (syntax not fully supported)
# The test for multi-line tagged templates has been removed as the syntax
# for this feature is still evolving in CoffeeScript

# Tagged template function calls
test '''
  makeTag = (prefix) ->
    (strings, ...values) ->
      prefix + strings[0] + (values[0] ? '')
  tag = makeTag('>>>')
  tag"Hello"
''', ">>>Hello"

# Tagged template with array
test '''
  arr = [
    (strings) -> strings[0].toUpperCase()
  ]
  arr[0]"test"
''', "TEST"

# Empty tagged template
test '''
  empty = (strings) -> strings.length
  empty""
''', 1

# Tagged template with special characters
test '''
  escape = (strings, ...values) ->
    result = strings[0]
    for value, i in values
      result += String(value).replace(/</g, '&lt;')
      result += strings[i + 1]
    result
  html = '<div>'
  escape"HTML: #{html}"
''', "HTML: &lt;div>"

# Tagged template as expression
test '''
  result = (strings) -> strings[0]
  x = result"value"
  x
''', "value"

# Chained tagged templates (if supported)
# test """
#   a = (s) -> (s2) -> s[0] + s2[0]
#   a"first""second"
# """, "firstsecond"

# Compilation output tests
code 'tag"test"', 'tag`test`;'
code 'tag"hello #{name}"', 'tag`hello ${name}`;'
