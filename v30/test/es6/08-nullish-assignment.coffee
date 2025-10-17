# Nullish Coalescing Assignment (??=) Tests
# Tests for Phase 8: ES2021's ??= operator

console.log "\n== Nullish Coalescing Assignment =="

# Test helper is defined globally by runner

# Basic nullish assignment
code '''
  x = null
  x ?= "default"
''', '''
  let x;

  x = null;

  x ??= "default";
'''

code '''
  y = undefined
  y ?= 42
''', '''
  let y;

  y = void 0;

  y ??= 42;
'''

# Existing values should not be overwritten
code '''
  z = "exists"
  z ?= "nope"
''', '''
  let z;

  z = "exists";

  z ??= "nope";
'''

# Object property assignment
code '''
  obj = {}
  obj.prop ?= "filled"
''', '''
  let obj;

  obj = {};

  obj.prop ??= "filled";
'''

# Nested object properties
code '''
  config = { database: {} }
  config.database.host ?= "localhost"
  config.database.port ?= 5432
''', '''
  let config;

  config = {
    database: {}
  };

  config.database.host ??= "localhost";

  config.database.port ??= 5432;
'''

# In class constructors
code '''
  class Settings
    constructor: ({theme, fontSize} = {}) ->
      @theme ?= "dark"
      @fontSize ?= 14
''', '''
  let Settings;

  Settings = class Settings {
    constructor({theme, fontSize} = {}) {
      this.theme ??= "dark";
      this.fontSize ??= 14;
    }

  };
'''

# In methods
code '''
  class Cache
    get: (key) ->
      @store ?= {}
      @store[key]
''', '''
  let Cache;

  Cache = class Cache {
    get(key) {
      this.store ??= {};
      return this.store[key];
    }

  };
'''

# Array element assignment
code '''
  arr = [null, undefined, "exists"]
  arr[0] ?= "first"
  arr[1] ?= "second"
  arr[2] ?= "nope"
''', '''
  let arr;

  arr = [null, void 0, "exists"];

  arr[0] ??= "first";

  arr[1] ??= "second";

  arr[2] ??= "nope";
'''

# Complex expressions
code '''
  getValue = -> null
  result = getValue()
  result ?= "fallback"
''', '''
  let getValue, result;

  getValue = () => null;

  result = getValue();

  result ??= "fallback";
'''

# Multiple assignments
code '''
  a = b = c = null
  a ?= 1
  b ?= 2
  c ?= 3
''', '''
  let a, b, c;

  a = b = c = null;

  a ??= 1;

  b ??= 2;

  c ??= 3;
'''

# In conditionals
code '''
  if someCondition
    value = null
    value ?= getDefault()
''', '''
  let value;

  if (someCondition) {
    value = null;
    value ??= getDefault();
  }
'''

# In loops
code '''
  for item in items
    item.processed ?= false
    item.timestamp ?= Date.now()
''', '''
  let i, item, len;

  for (i = 0, len = items.length; i < len; i++) {
    item = items[i];
    item.processed ??= false;
    item.timestamp ??= Date.now();
  }
'''

console.log "\n== Runtime Tests =="

test "nullish assignment with null", 'x = null; x ?= 5; x', 5

test "nullish assignment with undefined", 'y = undefined; y ?= "default"; y', "default"

test "preserves existing values", 'z = "exists"; z ?= "nope"; z', "exists"

test "works with object properties", 'obj = { prop: null }; obj.prop ?= "filled"; obj.prop', "filled"

test "works with falsy non-nullish values", 'x = 0; x ?= "changed"; x', 0

test "falsy false preserved", 'x = false; x ?= "changed"; x', false

test "falsy empty string preserved", 'x = ""; x ?= "changed"; x', ""

console.log "\nAll nullish assignment tests complete!"
