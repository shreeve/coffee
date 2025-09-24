# StringLiteral Solar Directive Tests
# ===================================
# Tests {$ast: 'StringLiteral'} directive processing

test '"hello"', "hello"
test "'world'", "world"
test '""', ""
test '"with spaces"', "with spaces"
test '"escape \\"quotes\\""', 'escape "quotes"'
test "'single with \\'quotes\\''", "single with 'quotes'"
