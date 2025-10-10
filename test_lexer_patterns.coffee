# Test patterns from lexer.coffee that are causing issues

# Pattern 1: Destructuring assignment without declaration
test1 = ->
  locationData = {range: []}
  [locationData.last_line, locationData.last_column, endOffset] =
    @getLineAndColumnFromChunk()
  console.log endOffset

# Pattern 2: Assignment in condition
test2 = ->
  return 0 unless (match = WHITESPACE.exec(@chunk)) or
                  (nline = @chunk.charAt(0) is '\n')
  console.log match, nline

# Pattern 3: Multiple destructuring
test3 = ->
  [a, b, c] = [1, 2, 3]
  [x, y, z] = [4, 5, 6]
  console.log a, x

test1()
test2()
test3()
