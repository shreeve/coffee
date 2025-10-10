# Test while loop with assignment
test = ->
  str = "hello world hello"
  while match = /hello/g.exec(str)
    console.log match
  
  # Test with destructuring  
  items = [[1,2], [3,4], [5,6]]
  i = 0
  while item = items[i++]
    [a, b] = item
    console.log a, b

test()
