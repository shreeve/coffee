# Test various conditional assignment patterns

# Assignment in if condition
test1 = ->
  return 0 unless (match = WHITESPACE.exec(@chunk))
  console.log match

# Assignment in or condition
test2 = ->
  return 0 unless (match = WHITESPACE.exec(@chunk)) or
                  (nline = @chunk.charAt(0) is '\n')
  console.log match, nline

# Assignment in while condition
test3 = ->
  while item = getNext()
    console.log item

# Assignment in complex condition
test4 = ->
  if (result = compute()) and result > 0
    console.log result

test1()
test2()
test3()
test4()
