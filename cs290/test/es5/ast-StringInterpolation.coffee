# String Interpolation Solar Directive Tests
# ===========================================
# Tests string interpolation processing

test 'name = "world"; "hello #{name}"', "hello world"
test '"result: #{1 + 2}"', "result: 3"
test '"value is #{42}"', "value is 42"
test 'x = "5"; y = "10"; "#{x} plus #{y}"', "5 plus 10"
test 'obj = {prop: "value"}; "nested #{obj.prop}"', "nested value"
test 'i = 0; "array[#{i}]"', "array[0]"
test '"bool: #{true}"', "bool: true"
test '"null: #{null}"', "null: null"
test '"math: #{2 * 3}"', "math: 6"
test 's = "test"; "string: #{s.toUpperCase()}"', "string: TEST"
test 'a = "x"; b = "y"; "multi #{a} and #{b}"', "multi x and y"
test '"empty #{}"', "empty "
test '"func: #{-> 5}"', "func: function() {\n    return 5;\n  }"
test '"expr: #{(x) -> x + 1}"', "expr: function(x) {\n    return x + 1;\n  }"
