# Module Syntax
# ===========================
# Tests for ES6 module import/export syntax parsing
# Note: These test syntax parsing, not actual module loading

# Import syntax variations (testing parsing only)
test "import 'module'; true", true
test "import foo from 'bar'; true", true
test "import {foo} from 'bar'; true", true
test "import {foo as bar} from 'baz'; true", true
test "import {foo, bar} from 'baz'; true", true
test "import foo, {bar} from 'baz'; true", true
test "import * as foo from 'bar'; true", true
test "import foo, * as bar from 'baz'; true", true

# Export syntax variations (testing parsing only)
test "export default 42; true", true
test "export {foo}; true", true
test "export {foo as bar}; true", true
test "export {foo, bar}; true", true
test "export * from 'module'; true", true
test "export {foo} from 'bar'; true", true
test "export {foo as bar} from 'baz'; true", true

# Export with declarations
test "export class MyClass {}; true", true
test "export myFunc = -> 42; true", true
test "export myVar = 123; true", true

# Import with line breaks
test """
  import {
    foo,
    bar,
    baz
  } from 'module'
  true
""", true

# Export with line breaks
test """
  export {
    foo,
    bar,
    baz
  }
  true
""", true

# Dynamic import (function call style)
test "import('./module').constructor.name", "Promise"

# Import assertions (stage 3 proposal)
# test "import json from './data.json' assert {type: 'json'}; true", true

# Import with trailing comma
test """
  import {
    foo,
    bar,
  } from 'module'
  true
""", true

# Export with trailing comma
test """
  export {
    foo,
    bar,
  }
  true
""", true

# Import all as namespace
test "import * as utils from 'utils'; true", true

# Re-export patterns
test "export {default} from 'other'; true", true
test "export {foo as default} from 'bar'; true", true
test "export * as utils from 'utils'; true", true

# Mixed import styles
test """
  import defaultExport, {
    namedExport1,
    namedExport2 as alias
  } from 'module'
  true
""", true

# Export from variable
test """
  myValue = 42
  export {myValue}
  true
""", true

# Export multiple defaults (should fail in real module)
# test "export default 1; export default 2; true", "should fail"

# Import in function (should parse)
test """
  loadModule = ->
    import('./dynamic')
  true
""", true
