# Test nullish coalescing operator (??) generation
# These tests verify that CoffeeScript's existential operator (?) compiles to ES6's nullish coalescing operator (??)

# Basic cases
code 'x = y ? "default"', 
     'var x;\n\nx = y ?? "default";'

code 'a = b ? c', 
     'var a;\n\na = b ?? c;'

# Chained existential operators
code 'result = a ? b ? c', 
     'var result;\n\nresult = a ?? b ?? c;'

code 'val = w ? x ? y ? z', 
     'var val;\n\nval = w ?? x ?? y ?? z;'

# Method calls with existential
code 'data = getData() ? {}', 
     'let data;\ndata = getData() ?? {};'

code 'result = obj.method() ? "fallback"', 
     'let result;\nresult = obj.method() ?? "fallback";'

# Property access
code 'val = obj.prop ? 0', 
     'let val;\nval = obj.prop ?? 0;'

code 'item = arr[index] ? defaultItem', 
     'let item;\nitem = arr[index] ?? defaultItem;'

# Inside expressions
code 'sum = (a ? 0) + (b ? 0)', 
     'let sum;\nsum = (a ?? 0) + (b ?? 0);'

code 'str = "Value: " + (val ? "none")', 
     'let str;\nstr = "Value: " + (val ?? "none");'

# With function calls
code 'fn = callback ? (-> console.log "default")', 
     'let fn;\nfn = callback ?? function() {\n  return console.log("default");\n};'

# Array/object literals
code 'config = userConfig ? {timeout: 1000}', 
     'let config;\nconfig = userConfig ?? {\n  timeout: 1000\n};'

code 'items = list ? []', 
     'let items;\nitems = list ?? [];'

# Prototype access (should work correctly)
code 'method = Array::find ? null', 
     'let method;\nmethod = Array.prototype.find ?? null;'

# Export with existential (for later when we add module support)
code 'export value = data ? 42', 
     'export var value = data ?? 42;'

# Inside conditionals
code 'if x ? y then z', 
     'if (x ?? y) {\n  z;\n}'

# Complex expressions
code 'result = (obj?.prop ? backup).toString()', 
     'let result;\nresult = ((obj != null ? obj.prop : void 0) ?? backup).toString();'

# Multiple on same line
code 'a = x ? 1; b = y ? 2', 
     'let a, b;\na = x ?? 1;\nb = y ?? 2;'

# In return statements
code '-> x ? "default"', 
     'function() {\n  return x ?? "default";\n};'

# Test that it handles parentheses correctly
code 'val = (a ? b) ? c', 
     'let val;\nval = (a ?? b) ?? c;'

# Test with boolean false (should NOT use nullish coalescing for explicit boolean test)
# Note: CoffeeScript's ? is for null/undefined, not falsy values
code 'val = isEnabled ? true',
     'let val;\nval = isEnabled ?? true;'

console.log "\n✨ Nullish Coalescing tests for basic ES6 transformation"
