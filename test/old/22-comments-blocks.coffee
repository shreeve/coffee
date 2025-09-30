# Comments and Block Comments
# ===========================
# Tests for single-line and block comments in various contexts

# Comments don't affect code execution
test "5 # this is a comment", 5
test "x = 10 # set x to 10\nx", 10
test "'hello' # comment", "hello"

# Block comments
test "### block comment ### 42", 42
test """
  ###
  This is a
  multi-line
  block comment
  ###
  123
""", 123

# Comments in objects
test "{a: 1, ### comment ### b: 2}.b", 2
test """
  obj = {
    x: 10  # first property
    y: 20  # second property
  }
  obj.x + obj.y
""", 30

# Comments in arrays
test "[1, ### comment ### 2, 3].length", 3
test """
  arr = [
    1  # first
    2  # second
    3  # third
  ]
  arr[1]
""", 2

# Comments in function calls
test "Math.max(1, ### comment ### 2, 3)", 3
test """
  add = (a, b) -> a + b
  add(
    5  # first arg
    10 # second arg
  )
""", 15

# Comments in conditionals
test """
  x = 5
  if x > 3  # check if greater
    'yes'
  else
    'no'
""", "yes"

# Comments before line continuations
test """
  1 + # comment
  2 + # another
  3
""", 6

# Block comments that look like regex
test "### /not/a/regex/ ### true", true
test "######## 8 hashes ######## true", true

# Comments in switch
test """
  x = 2
  switch x
    when 1  # first case
      'one'
    ### block comment ###
    when 2  # second case
      'two'
    else
      'other'
""", "two"

# Comments in classes
test """
  class MyClass
    # This is a comment
    constructor: ->
      @value = 5

    ###
    Block comment
    ###
    method: ->
      @value

  (new MyClass).method()
""", 5

# Comments in comprehensions
test "(x for x in [1, 2, 3] ### filter comment ### when x > 1).join(',')", "2,3"
test """
  (
    x * 2  # double it
    for x in [1, 2, 3]
  ).join(',')
""", "2,4,6"

# Inline comments don't break expressions
test "1 +### inline ###2", 3
test "x =### comment ###5; x", 5

# Comments at end of file (no trailing newline issues)
test "42 # last line comment", 42

# Unicode in comments
test "5 # 你好世界", 5
test "10 # café ☕️", 10
test "### émoji 😀 ### 7", 7

# Comments that look like other syntax
test "1 # => not an arrow", 1
test "2 # -> not a function", 2
test "3 # #{} not interpolation", 3

# Block comment edge cases
test "x = ###a### 5; x", 5
test "###a###5", 5
test "1###comment###2", undefined  # This concatenates as 12 without space
test "1 ###comment### 2", undefined  # Space makes it invalid

# Comments with special characters
test "1 # comment with 'quotes'", 1
test '2 # comment with "double quotes"', 2
test "3 # comment with \\backslash", 3

# Comments breaking up operators (should not work)
# test "1 +# comment\n 2", 3  # This might fail depending on implementation

# Block comments as expressions (should be undefined)
test "x = ### just a comment ###; x", undefined

# Comments in destructuring
test "[a, ### comment ### b] = [1, 2]; b", 2
test "{x ### comment ###} = {x: 5}; x", 5

# Compilation output tests - comments are stripped
code "# comment\nx = 1", "var x;\n\nx = 1;"
code "### block ###\ny = 2", "var y;\n\ny = 2;"
