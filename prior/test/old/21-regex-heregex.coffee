# Regular Expressions and Heregex
# ===========================
# Tests for regular expressions, including heregex (multiline regex with comments)

# Basic regex literals
test "/test/.test('test')", true
test "/Test/i.test('test')", true
test "/\\d+/.test('123')", true
test "/[a-z]+/.test('hello')", true
test "/^start/.test('start of line')", true
test "/end$/.test('at the end')", true

# Regex flags
test "/test/g.global", true
test "/test/i.ignoreCase", true
test "/test/m.multiline", true
test "/./s.dotAll", true  # ES2018 dotall flag
test "/test/u.unicode", true  # Unicode flag
test "/test/y.sticky", true  # Sticky flag

# Character classes
test "/[abc]/.test('b')", true
test "/[^abc]/.test('d')", true
test "/[a-zA-Z]/.test('F')", true
test "/[0-9]/.test('5')", true
test "/[\\s]/.test(' ')", true
test "/[\\S]/.test('a')", true

# Quantifiers
test "/a*/.test('')", true
test "/a+/.test('a')", true
test "/a?/.test('')", true
test "/a{3}/.test('aaa')", true
test "/a{2,4}/.test('aaa')", true
test "/a{2,}/.test('aaaa')", true

# Capturing groups
test "/(\\d+)/.exec('abc123')[1]", "123"
test "/(\\w+)\\s+(\\w+)/.exec('hello world')[2]", "world"
test "/(?:test)/.test('test')", true  # Non-capturing group

# Backreferences
test "/(a)(b)\\2\\1/.test('abba')", true
test "/(\\w)\\1/.test('hello')", true

# Lookahead/lookbehind
test "/foo(?=bar)/.test('foobar')", true
test "/foo(?!bar)/.test('foobaz')", true
test "/(?<=foo)bar/.test('foobar')", true  # Lookbehind (ES2018)
test "/(?<!foo)bar/.test('xbar')", true  # Negative lookbehind

# Heregex (multiline regex with comments)
test "///test///.test('test')", true
test "///\\d+///.test('123')", true
test """
  ///
    ^       # Start of line
    \\d+    # One or more digits
    $       # End of line
  ///.test('123')
""", true

test """
  ///
    [a-z]+  # Lowercase letters
    \\s+    # Whitespace
    [0-9]+  # Digits
  ///.test('hello 123')
""", true

# Heregex with interpolation - Note: interpolating '\d' doesn't work as expected
# The string '\d' becomes literal 'd', not the regex pattern \d
# This test is fundamentally flawed in both CS28 and CS29
test """
  digit = '\\\\d'
  ///\#{digit}+///.test('123')
""", true

test '''
  start = '^'
  end = '$'
  ///#{start}test#{end}///.test('test')
''', true

# Empty heregex
test "//////.source", "(?:)"
fail "///.source", "missing ///"

# Heregex with flags
test "///test///i.test('TEST')", true
test "///a.b///s.test('a\\nb')", true  # Dotall flag
test "///^\\d+$///m.test('line1\\n123\\nline3')", true

# Special characters in regex
test "/\\n/.test('\\n')", true
test "/\\t/.test('\\t')", true
test "/\\r/.test('\\r')", true
test "/\\\\/.test('\\\\')", true
test "/\\//.test('/')", true

# Unicode escapes in regex
test "/\\u0041/.test('A')", true
test "/\\x41/.test('A')", true
test "/\\u{1F600}/u.test('😀')", true  # Unicode code point escape

# Regex methods
test "'test123'.match(/\\d+/)[0]", "123"
test "'hello world'.replace(/world/, 'coffee')", "hello coffee"
test "'a,b,c'.split(/,/).length", 3
test "'test test'.search(/test/)", 0

# Complex heregex patterns
test """
  emailRegex = ///
    ^                 # Start
    [\\w.+-]+         # Username
    @                 # At symbol
    [\\w.-]+          # Domain
    \\.               # Dot
    [a-zA-Z]{2,}      # TLD
    $                 # End
  ///
  emailRegex.test('user@example.com')
""", true

# Regex in conditionals
test "if /test/.test('test') then true else false", true
test "result = 'pass' if /\\d/.test('123'); result", "pass"

# Regex with exec
test "/([a-z]+)-(\\d+)/.exec('test-123')[1]", "test"
test "/([a-z]+)-(\\d+)/.exec('test-123')[2]", "123"

# Global regex with multiple matches
test """
  matches = []
  regex = /(\\w+)/g
  str = 'one two three'
  while match = regex.exec(str)
    matches.push(match[1])
  matches.join(',')
""", "one,two,three"

# Regex source and toString
test "/test/.source", "test"
test "/test/gi.toString()", "/test/gi"

# Division vs regex disambiguation
test "x = 10; y = 2; x / y", 5
test "x = 10; y = 2; z = x / y / 2; z", 2.5
test "fn = -> 10\nfn() / 2", 5

# Edge cases
test "/]/.test(']')", true  # Closing bracket doesn't need escaping
test "/[\\]]/.test(']')", true  # But can be escaped
test "/{/.test('{')", true  # Curly braces
test "/}/.test('}')", true

# Compilation output tests
code "/test/", "/test/;"
code "///a b c///", "/abc/;"
