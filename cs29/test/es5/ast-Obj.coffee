# Obj Solar Directive Tests
# ========================
# Tests {$ast: 'Obj'} directive processing

test "{}", {}
test "{name: 'hello'}", {name: 'hello'}
test "{x: 1, y: 2}", {x: 1, y: 2}
test "{value: 42}", {value: 42}
test "{a: true, b: false}", {a: true, b: false}
test "{nested: {inner: 123}}", {nested: {inner: 123}}
