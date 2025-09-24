# ThisLiteral Solar Directive Tests  
# ===================================
# Tests {$ast: 'ThisLiteral'} directive processing

test "@", this
test "this", this
test "@length", this?.length
test "this.toString", this?.toString
