# String Methods Solar Directive Tests
# ====================================
# Tests string method calls and operations

test "'hello'.length", 5
test "'world'.toUpperCase()", "WORLD"
test "'TEST'.toLowerCase()", "test"
test "'hello world'.split(' ')", ['hello', 'world']
test "'  trim  '.trim()", "trim"
test "'abc'.charAt(1)", "b"
test "'abc'.charCodeAt(0)", 97
test "'hello'.indexOf('ell')", 1
test "'test'.includes('es')", true
test "'start'.startsWith('st')", true
test "'end'.endsWith('nd')", true
test "'repeat'.repeat(2)", "repeatrepeat"
test "'slice'.slice(1, 3)", "li"
test "'substring'.substring(0, 3)", "sub"
test "'replace'.replace('e', 'E')", "rEplace"
test "String.fromCharCode(65, 66)", "AB"
test "String('number')", "number"
