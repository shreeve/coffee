# Strings and Interpolation
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify string features work correctly

# Basic string literals
test "'hello'", "hello"
test '"world"', "world"
test "'hello' + ' ' + 'world'", "hello world"
test '"a" + "b" + "c"', "abc"

# String escapes
test "'it\\'s'", "it's"
test '"say \\"hi\\""', 'say "hi"'
test "'line1\\nline2'.indexOf('\\n')", 5
test "'tab\\there'.indexOf('\\t')", 3

# Multiline strings
test '"""hello"""', "hello"
test '"""line1\nline2"""', "line1\nline2"
test "'''single\nquotes'''", "single\nquotes"

# String interpolation
test '"value: #{5 + 3}"', "value: 8"
test 'x = 10; "x is #{x}"', "x is 10"
test 'name = "World"; "Hello, #{name}!"', "Hello, World!"

# Nested interpolation
test 'x = 5; y = 10; "sum: #{x + y}, product: #{x * y}"', "sum: 15, product: 50"
test '"#{"nested"}"', "nested"
test 'a = 2; b = 3; "#{a} + #{b} = #{a + b}"', "2 + 3 = 5"

# Interpolation with expressions
test '"result: #{if true then "yes" else "no"}"', "result: yes"
test 'arr = [1, 2, 3]; "array: #{arr.join(\', \')}"', "array: 1, 2, 3"
test '"calc: #{(-> 42)()}"', "calc: 42"

# String methods
test "'hello'.length", 5
test "'hello'.toUpperCase()", "HELLO"
test "'WORLD'.toLowerCase()", "world"
test "'hello'[0]", "h"
test "'hello'.charAt(1)", "e"
test "'hello'.charCodeAt(0)", 104

# String slicing
test "'hello'[1..3]", "ell"
test "'hello'[1...4]", "ell"
test "'hello'[..2]", "hel"
test "'hello'[2..]", "llo"
test "'hello'[-3..]", "llo"

# String search methods
test "'hello world'.indexOf('world')", 6
test "'hello'.indexOf('x')", -1
test "'hello hello'.lastIndexOf('hello')", 6
test "'hello'.includes('ell')", true
test "'hello'.includes('x')", false

# String replace
test "'hello'.replace('l', 'L')", "heLlo"
test "'hello'.replace(/l/g, 'L')", "heLLo"
test "'hello world'.replace('world', 'coffee')", "hello coffee"

# String split
test "'a,b,c'.split(',').join('-')", "a-b-c"
test "'hello'.split('').join('-')", "h-e-l-l-o"
test "'one two three'.split(' ').length", 3

# String trim
test "'  hello  '.trim()", "hello"
test "'  hello'.trimStart()", "hello"
test "'hello  '.trimEnd()", "hello"

# String padding
test "'5'.padStart(3, '0')", "005"
test "'5'.padEnd(3, '0')", "500"
test "'hi'.padStart(5, 'x')", "xxxhi"

# String repeat
test "'ab'.repeat(3)", "ababab"
test "'x'.repeat(5)", "xxxxx"
test "''.repeat(10)", ""

# String comparison
test "'a' < 'b'", true
test "'b' > 'a'", true
test "'hello' is 'hello'", true
test "'hello' is 'world'", false

# Template literals (backticks are for embedded JS in CoffeeScript, not template strings)
# test "`plain`", "plain"  # This becomes a variable reference, not a string
# test "x = 5; `value: ${x}`", "value: 5"  # Backticks don't work as template literals

# String concatenation with +
test "'hello' + ' ' + 'world'", "hello world"
test "'a' + 'b' + 'c' + 'd'", "abcd"
test "'' + 'test'", "test"

# Numbers in string interpolation
test 'x = 42; "answer: #{x}"', "answer: 42"
test '"pi: #{3.14159}"', "pi: 3.14159"
test '"calc: #{2 * 3}"', "calc: 6"

# Booleans in string interpolation
test '"bool: #{true}"', "bool: true"
test '"bool: #{false}"', "bool: false"
test 'x = true; "value: #{x}"', "value: true"

# Arrays in string interpolation
test 'arr = [1, 2, 3]; "#{arr}"', "1,2,3"
test '"array: #{[1, 2, 3]}"', "array: 1,2,3"

# Objects in string interpolation
test 'obj = {toString: -> "custom"}; "#{obj}"', "custom"
test '"object: #{{}}"', "object: [object Object]"

# Null/undefined in strings
test '"value: #{null}"', "value: null"
test '"value: #{undefined}"', "value: undefined"

# String startsWith/endsWith
test "'hello'.startsWith('hel')", true
test "'hello'.startsWith('ell')", false
test "'hello'.endsWith('llo')", true
test "'hello'.endsWith('hel')", false

# String match
test "'hello'.match(/l+/)[0]", "ll"
test "'test123'.match(/\\d+/)[0]", "123"
test "'hello'.match(/x/)", null

# Raw strings (no interpolation in single quotes)
test '\'#{5}\'', '#{5}'
test '\'value: #{x}\'', 'value: #{x}'

# Escape sequences
test '"\\n".length', 1
test '"\\t".length', 1
test '"\\\\".length', 1
test '"\\u0048"', "H"

# Block strings preserve indentation
test """
  '''
    indented
      text
  '''
""", "indented\n  text"  # Triple quotes strip common leading whitespace

# Empty strings
test '""', ""
test "''", ""
test '""""""', ""
test "''''''", ""

# String coercion
test "'' + 5", "5"
test "'' + true", "true"
test "'' + null", "null"
test "'' + undefined", "undefined"
test "'' + []", ""
test "'' + [1, 2]", "1,2"

# Unicode strings
test '"😀".length', 2  # Emoji is 2 code units
test '"café".length', 4
test '"日本語"[0]', "日"
