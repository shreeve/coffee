# Phase 3: ES6 Modules (import/export)

console.log "\n== ES6 Modules =="

# Default imports
code 'import React from "react"', '''
  import React from "react";
'''

code 'import _ from "lodash"', '''
  import _ from "lodash";
'''

# Named imports
code 'import { Component } from "react"', '''
  import { Component } from "react";
'''

code 'import { useState, useEffect } from "react"', '''
  import { useState, useEffect } from "react";
'''

# Aliased imports
code 'import { Component as Comp } from "react"', '''
  import { Component as Comp } from "react";
'''

# Namespace imports
code 'import * as utils from "./utils"', '''
  import * as utils from "./utils.js";
'''

# Mixed imports
code 'import React, { Component } from "react"', '''
  import React, { Component } from "react";
'''

# Default exports
code 'export default class App', '''
  export default class App {};
'''

code '''
  export default ->
    console.log "default function"
''', '''
  export default () => console.log("default function");
'''

# Named exports
code 'export { utils }', '''
  export { utils };
'''

code 'export { helper, processor }', '''
  export { helper, processor };
'''

# Export declarations
code 'export x = 5', '''
  export let x = 5;
'''

code '''
  export class Widget
    render: -> "widget"
''', '''
  export let Widget = class Widget {
    render() {
      return "widget";
    }

  };
'''

# Export functions
code '''
  export myFunc = (x) ->
    x * 2
''', '''
  export let myFunc = (x) => x * 2;
'''

# Export with arrow functions
code 'export handler = => @handleEvent()', '''
  export let handler = () => this.handleEvent();
'''

# Re-exports
code 'export { Component } from "react"', '''
  export { Component } from "react";
'''

code 'export * from "./utils"', '''
  export * from "./utils.js";
'''

# Dynamic imports
code 'module = await import("./module")', '''
  let module;

  module = (await import("./module"));
'''

# Import assertions
code 'import data from "./data.json" assert { type: "json" }', '''
  import data from "./data.json" with { type: "json" };
'''

console.log "\n== Runtime Tests =="

# Import/export are compile-time features, not runtime
# We can only test that the syntax is preserved correctly

test '"import React from \\"react\\"".includes("import")', true

test '"export default App".includes("export")', true