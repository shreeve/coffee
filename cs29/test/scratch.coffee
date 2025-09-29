#!/usr/bin/env coffee

# ==============================================================================
# scratch.coffee - A scratch file for testing CoffeeScript code, add them below.
# ==============================================================================

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
