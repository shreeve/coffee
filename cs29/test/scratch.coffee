#!/usr/bin/env coffee

# Scratch Test File
# =================
# Drop your one-off tests here for quick testing
# Run with: npm run test test/scratch.coffee

# Example tests - replace with your own:

test "1 + 1", 2

test "typeof []", "object"

test "'hello' + ' world'", "hello world"

# Add your tests below:

test "(\"#{i}:#{v}\" for v, i in ['a', 'b', 'c']).join(',')", "0:a,1:b,2:c"

# Do-while pattern
test """
  i = 0
  result = []
  loop
    result.push(i)
    i++
    break unless i < 3
  result.join(',')
""", "0,1,2"

