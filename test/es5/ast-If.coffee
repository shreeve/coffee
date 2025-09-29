# If Solar Directive Tests
# ========================
# Tests {$ast: 'If'} directive processing

test "if true then 5", 5
test "if false then 1 else 2", 2
test "if 1 then 'yes'", "yes"
test "if 0 then 'no' else 'zero'", "zero"
test "unless false then 10", 10
test "unless true then 1 else 20", 20
