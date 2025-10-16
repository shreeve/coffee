###
Import/Export Tests for ES6 Output
===================================

This test suite defines the expected ES6 output for import/export statements.
We test the following transformations:
- Auto-add .js extension to relative imports (not packages)
- Add 'with { type: "json" }' for JSON imports
- Use 'let' for all exports (consistent with pure let philosophy)
- Static imports must be at top of file (ES6 requirement)

Run with: cd v30 && ES6=1 coffee test/runner.coffee test/es6/import-export.coffee
###

# ==============================================================================
# BASIC IMPORTS
# ==============================================================================

console.log "\n== Basic Imports =="

# Default import from package (no .js extension added)
code "import React from 'react'", '''
  import React from 'react';
'''

# Default import from relative path (adds .js extension)
code "import utils from './utils'", '''
  import utils from './utils.js';
'''

# Default import from parent directory
code "import shared from '../shared'", '''
  import shared from '../shared.js';
'''

# Default import from nested path
code "import Button from './components/Button'", '''
  import Button from './components/Button.js';
'''

# Import with existing extension (no .js added)
code "import Component from './Component.tsx'", '''
  import Component from './Component.tsx';
'''

# Import from index file
code "import helpers from './helpers/index'", '''
  import helpers from './helpers/index.js';
'''

# ==============================================================================
# NAMED IMPORTS
# ==============================================================================

console.log "\n== Named Imports =="

# Named imports from package
code "import { readFile, writeFile } from 'fs'", '''
  import { readFile, writeFile } from 'fs';
'''

# Named imports from relative path
code "import { helper, formatter } from './utils'", '''
  import { helper, formatter } from './utils.js';
'''

# Single named import
code "import { useState } from 'react'", '''
  import { useState } from 'react';
'''

# Named import with rename
code "import { Component as Comp } from 'react'", '''
  import { Component as Comp } from 'react';
'''

# Multiple named imports with rename
code "import { readFile as read, writeFile as write } from 'fs'", '''
  import { readFile as read, writeFile as write } from 'fs';
'''


# ==============================================================================
# MIXED IMPORTS
# ==============================================================================

console.log "\n== Mixed Imports =="

# Default and named imports together
code "import React, { Component, useState } from 'react'", '''
  import React, { Component, useState } from 'react';
'''

# Default and named imports from relative path
code "import defaultExport, { namedExport } from './module'", '''
  import defaultExport, { namedExport } from './module.js';
'''

# ==============================================================================
# NAMESPACE IMPORTS
# ==============================================================================

console.log "\n== Namespace Imports =="

# Import all as namespace
code "import * as utils from './utils'", '''
  import * as utils from './utils.js';
'''

# Import all from package
code "import * as lodash from 'lodash'", '''
  import * as lodash from 'lodash';
'''

# ==============================================================================
# JSON IMPORTS
# ==============================================================================

console.log "\n== JSON Imports =="

# JSON import (adds with { type: "json" })
code "import config from './config.json'", '''
  import config from './config.json' with { type: "json" };
'''

# JSON import from nested path
code "import data from '../data/settings.json'", '''
  import data from '../data/settings.json' with { type: "json" };
'''

# JSON with uppercase extension
code "import manifest from './manifest.JSON'", '''
  import manifest from './manifest.JSON' with { type: "json" };
'''

# ==============================================================================
# SIDE EFFECT IMPORTS
# ==============================================================================

console.log "\n== Side Effect Imports =="

# Import for side effects only
code "import './polyfills'", '''
  import './polyfills.js';
'''

# Import CSS (keeps extension)
code "import './styles.css'", '''
  import './styles.css';
'''

# Import package for side effects
code "import 'reflect-metadata'", '''
  import 'reflect-metadata';
'''

# ==============================================================================
# BASIC EXPORTS
# ==============================================================================

console.log "\n== Basic Exports =="

# Named export of variable (uses let)
code "export x = 5", '''
  export let x = 5;
'''

# Named export of function (uses let)
code '''
  export myFunc = (x) ->
    x * 2
''', '''
  export let myFunc = function(x) {
    return x * 2;
  };
'''

# Named export of arrow function
code "export handler = => @handleEvent()", '''
  export let handler = () => {
    return this.handleEvent();
  };
'''

# Named export of class (uses let)
code '''
  export class User
    constructor: (@name) ->
''', '''
  export let User = class User {
    constructor(name) {
      this.name = name;
    }

  };
'''

# ==============================================================================
# DEFAULT EXPORTS
# ==============================================================================

console.log "\n== Default Exports =="

# Default export of value
code "export default 42", '''
  export default 42;
'''

# Default export of function
code '''
  export default ->
    console.log 'default function'
''', '''
  export default function() {
    return console.log('default function');
  };
'''

# Default export of class
code '''
  export default class App
    render: -> 'app'
''', '''
  export default class App {
    render() {
      return 'app';
    }

  };
'''

# Default export of object
code '''
  export default
    name: 'module'
    version: '1.0.0'
''', '''
  export default {
    name: 'module',
    version: '1.0.0'
  };
'''

# ==============================================================================
# EXPORT LISTS
# ==============================================================================

console.log "\n== Export Lists =="


# Export single item
code "export { myFunc }", '''
  export { myFunc };
'''

# Export multiple items
code "export { x, y, z }", '''
  export { x, y, z };
'''

# Export with rename
code "export { internal as external }", '''
  export { internal as external };
'''

# Export multiple with rename
code "export { x as a, y as b }", '''
  export { x as a, y as b };
'''

# ==============================================================================
# RE-EXPORTS
# ==============================================================================

console.log "\n== Re-exports =="

# Re-export all
code "export * from './utils'", '''
  export * from './utils.js';
'''


# Re-export specific items
code "export { helper, formatter } from './utils'", '''
  export { helper, formatter } from './utils.js';
'''

# Re-export with rename
code "export { default as MyComponent } from './Component'", '''
  export { default as MyComponent } from './Component.js';
'''

# Re-export from package (no .js added)
code "export { useState } from 'react'", '''
  export { useState } from 'react';
'''

# ==============================================================================
# IMPORT ASSERTIONS (OTHER THAN JSON)
# ==============================================================================

console.log "\n== Import Assertions =="

# CSS module with assertion
code "import styles from './styles.css' assert { type: 'css' }", '''
  import styles from './styles.css' assert { type: 'css' };
'''

# Multiple assertions
code "import data from './data' assert { type: 'json', integrity: 'sha256-...' }", '''
  import data from './data.js' assert { type: 'json', integrity: 'sha256-...' };
'''

# ==============================================================================
# COMPLEX PATTERNS
# ==============================================================================

console.log "\n== Complex Patterns =="

# Multiple imports in sequence
code '''
  import React from 'react'
  import { render } from 'react-dom'
  import App from './App'
''', '''
  import React from 'react';
  import { render } from 'react-dom';
  import App from './App.js';
'''

# Import and export in same file
code '''
  import { helper } from './utils'
  export processData = (data) ->
    helper(data)
''', '''
  import { helper } from './utils.js';
  export let processData = function(data) {
    return helper(data);
  };
'''

# Export at declaration
code '''
  export class Service
    @staticMethod: -> 'static'
    instanceMethod: -> 'instance'
''', '''
  export let Service = class Service {
    static staticMethod() {
      return 'static';
    }

    instanceMethod() {
      return 'instance';
    }

  };
'''

# ==============================================================================
# EDGE CASES
# ==============================================================================

console.log "\n== Edge Cases =="

# Path with multiple dots
code "import data from './file.config.json'", '''
  import data from './file.config.json' with { type: "json" };
'''

# Deep relative path
code "import component from '../../components/shared/Button'", '''
  import component from '../../components/shared/Button.js';
'''

# Import from node_modules (no .js)
code "import pkg from 'some-package/dist/index'", '''
  import pkg from 'some-package/dist/index';
'''

# Scoped package
code "import tool from '@babel/core'", '''
  import tool from '@babel/core';
'''

# Export with computed property name (not standard but for completeness)
code '''
  key = 'dynamic'
  export obj =
    [key]: 'value'
''', '''
  let key;

  key = 'dynamic';

  export let obj = {
    [key]: 'value'
  };
'''

# ==============================================================================
# IMPORT POSITIONING
# ==============================================================================

console.log "\n== Import Positioning =="

# Note: Imports must be at top-level - these should produce errors if placed incorrectly
# We're testing that they compile correctly when at the proper position

# Valid: Import at top of file
code '''
  import fs from 'fs'
  console.log fs
''', '''
  import fs from 'fs';
  console.log(fs);
'''

# Valid: Multiple imports at top
code '''
  import path from 'path'
  import fs from 'fs'

  doWork = ->
    fs.readFile 'test.txt'
''', '''
  import path from 'path';
  import fs from 'fs';
  let doWork;

  doWork = function() {
    return fs.readFile('test.txt');
  };
'''

console.log "\n== Test Complete =="
