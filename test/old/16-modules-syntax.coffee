# Module Syntax
# ===========================
# Tests for ES6 module import/export syntax parsing
# Note: These test syntax parsing, not actual module loading

# Import/export syntax (will fail without proper module system, but tests syntax)
# test "import {readFile} from 'fs'; typeof readFile", "function"
# test "import * as fs from 'fs'; typeof fs", "object"
# test "export default class MyClass; true", true
# test "export {myFunc, myVar}; true", true

# Import syntax variations (testing compilation only - cannot execute ES6 modules)
code "import 'module'", "import 'module';"
code "import foo from 'bar'", "import foo from 'bar';"
code "import {foo} from 'bar'", "import {\n  foo\n} from 'bar';"
code "import {foo as bar} from 'baz'", "import {\n  foo as bar\n} from 'baz';"
code "import {foo, bar} from 'baz'", "import {\n  foo,\n  bar\n} from 'baz';"
code "import foo, {bar} from 'baz'", "import foo, {\n  bar\n} from 'baz';"
code "import * as foo from 'bar'", "import * as foo from 'bar';"
code "import foo, * as bar from 'baz'", "import foo, * as bar from 'baz';"

# Export syntax variations (testing compilation only)
code "export default 42", "export default 42;"
code "export {foo}", "export {\n  foo\n};"
code "export {foo as bar}", "export {\n  foo as bar\n};"
code "export {foo, bar}", "export {\n  foo,\n  bar\n};"
code "export * from 'module'", "export * from 'module';"
code "export {foo} from 'bar'", "export {\n  foo\n} from 'bar';"
code "export {foo as bar} from 'baz'", "export {\n  foo as bar\n} from 'baz';"

# Export with declarations
code "export class MyClass", "export var MyClass = class MyClass {};"
code "export myFunc = -> 42", "export var myFunc = function() {\n  return 42;\n};"
code "export myVar = 123", "export var myVar = 123;"

# Import with line breaks
code """
  import {
    foo,
    bar,
    baz
  } from 'module'
""", """import {
  foo,
  bar,
  baz
} from 'module';"""

# Export with line breaks
code """
  export {
    foo,
    bar,
    baz
  }
""", """export {
  foo,
  bar,
  baz
};"""

# Dynamic import (function call style)
test "import('./module').constructor.name", "Promise"

# Import assertions (stage 3 proposal)
# test "import json from './data.json' assert {type: 'json'}; true", true

# Import with trailing comma
code """
  import {
    foo,
    bar,
  } from 'module'
""", """import {
  foo,
  bar
} from 'module';"""

# Export with trailing comma
code """
  export {
    foo,
    bar,
  }
""", """export {
  foo,
  bar
};"""

# Import all as namespace
code "import * as utils from 'utils'", "import * as utils from 'utils';"

# Re-export patterns
code "export {default} from 'other'", "export {\n  default\n} from 'other';"
code "export {foo as default} from 'bar'", "export {\n  foo as default\n} from 'bar';"
fail "export * as utils from 'utils'", "unexpected as"

# Mixed import styles
code """
  import defaultExport, {
    namedExport1,
    namedExport2 as alias
  } from 'module'
""", """import defaultExport, {
  namedExport1,
  namedExport2 as alias
} from 'module';"""

# Export from variable
code """
  myValue = 42
  export {myValue}
""", """var myValue;

myValue = 42;

export {
  myValue
};"""

# Export multiple defaults (should fail in real module)
# test "export default 1; export default 2; true", "should fail"

# Import in function (should parse)
code """
  loadModule = ->
    import('./dynamic')
""", """var loadModule;

loadModule = function() {
  return import('./dynamic');
};"""

# Compilation output tests
code "import x from 'y'", "import x from 'y';"
code "export default class A", "var A;\n\nexport default A = class A {};"
code "export {a, b}", "export {\n  a,\n  b\n};"
