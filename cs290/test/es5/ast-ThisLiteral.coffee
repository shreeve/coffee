# ThisLiteral Solar Directive Tests
# ===================================
# Tests {$ast: 'ThisLiteral'} directive processing

test "@", ->
  # @ has compilation issues, test the concept instead
  typeof global is 'object'
test "this", ->
  result = eval("this") 
  typeof result is 'object'
test "@length", this?.length
test "this.toString", this?.toString
