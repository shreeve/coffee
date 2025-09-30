test '''
  ///
    [a-z]+  # Lowercase letters
    \\s+     # Whitespace (escaped backslash)
    [0-9]+  # Digits
  ///.test('hello 123')
''', true
