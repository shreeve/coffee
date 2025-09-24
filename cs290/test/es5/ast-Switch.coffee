# Switch Solar Directive Tests
# ============================
# Tests {$ast: 'Switch'} directive processing

test "switch 1 when 1 then 'one'", "one"
test "switch 2 when 1 then 'one' when 2 then 'two'", "two"
test "switch 3 when 1, 2 then 'low' else 'high'", "high"
test "switch true when false then 'no' else 'yes'", "yes"
test "switch 'a' when 'b' then 1 when 'a' then 2", 2
test "switch 0 when 1 then 'one' else 'other'", "other"
