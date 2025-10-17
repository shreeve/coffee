# RegexLiteral Solar Directive Tests
# ===================================
# Tests {$ast: 'RegexLiteral'} directive processing

test "/test/", /test/
test "/hello/g", /hello/g
test "/^start/", /^start/
test "/end$/i", /end$/i
test "/a.b/", /a.b/
test "/\\d+/", /\d+/
