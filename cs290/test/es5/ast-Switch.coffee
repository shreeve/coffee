# Switch Solar Directive Tests
# ============================
# Tests {$ast: 'Switch'} directive processing

# Note: CoffeeScript switch statements require indentation
# We can't test inline switch as it's not valid syntax
# These tests use assignment to capture switch results

test "x = (switch 1\n  when 1 then 'one'\n  when 2 then 'two'); x", "one"
test "x = (switch 2\n  when 1 then 'one'\n  when 2 then 'two'); x", "two"
test "x = (switch 3\n  when 1, 2 then 'low'\n  else 'high'); x", "high"
test "x = (switch true\n  when false then 'no'\n  else 'yes'); x", "yes"
test "x = (switch 'a'\n  when 'b' then 1\n  when 'a' then 2); x", 2
test "x = (switch 0\n  when 1 then 'one'\n  else 'other'); x", "other"
test "y = 5; x = (switch y\n  when 5 then 'five'\n  else 'not five'); x", "five"
test "x = (switch 10\n  when 1 then 'one'\n  when 2, 3, 4 then 'small'\n  when 5, 6, 7, 8, 9 then 'medium'\n  else 'large'); x", "large"
test "grade = 85; x = (switch\n  when grade >= 90 then 'A'\n  when grade >= 80 then 'B'\n  when grade >= 70 then 'C'\n  else 'F'); x", "B"
test "type = 'string'; x = (switch type\n  when 'number', 'string' then 'primitive'\n  when 'object', 'function' then 'complex'\n  else 'unknown'); x", "primitive"
test "day = 3; x = (switch day\n  when 0, 6 then 'weekend'\n  when 1, 2, 3, 4, 5 then 'weekday'); x", "weekday"
test "x = (switch null\n  when null then 'null'\n  else 'not null'); x", "null"
test "x = (switch undefined\n  when undefined then 'undefined'\n  else 'not undefined'); x", "undefined"