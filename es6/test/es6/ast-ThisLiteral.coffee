# ThisLiteral Solar Directive Tests
# ===================================
# Tests {$ast: 'ThisLiteral'} directive processing

# Simple tests for @ and this
# In eval() context, @ and this return the global object
test "typeof @", "object"
test "typeof this", "object"
test "@constructor", @constructor
test "this.constructor", this.constructor
