# Fix for Export IIFE Issue

## Problem
When CoffeeScript classes have instance properties (like `children: ['body']`), they get wrapped in IIFEs. When exported, this generates invalid ES6 syntax:

```javascript
export (function() {
  class SomeClass extends Base {
    // ...
  }
  SomeClass.prototype.children = ['body'];
  return SomeClass;
}).call(this);
```

This is invalid ES6 - you cannot export an IIFE directly.

## Current Status
- Fixed Base class by moving properties to constructor
- 58 other classes still have IIFE wrappers due to instance properties

## Solutions

### Option 1: Modify CoffeeScript Compiler (Complex)
Modify cs29/src/nodes6.coffee to detect when we're exporting a class with instance properties and generate different code for ES6.

### Option 2: Post-Process Generated JavaScript (Simple)
Create a script to fix the generated JavaScript files:

```javascript
// fix-export-iife.js
const fs = require('fs');
const path = require('path');

function fixExportIIFE(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');

  // Match export (function() { ... }).call(this);
  const pattern = /export \(function\(\) \{([\s\S]*?)\}\)\.call\(this\);/g;

  content = content.replace(pattern, (match, body) => {
    // Extract the class and return it directly
    const returnMatch = body.match(/return (\w+);$/m);
    if (returnMatch) {
      const className = returnMatch[1];
      // Remove the return statement and export the class directly
      const cleanBody = body.replace(/return \w+;$/m, '').trim();
      return `${cleanBody}\nexport { ${className} };`;
    }
    return match; // If we can't parse it, leave it unchanged
  });

  fs.writeFileSync(filePath, content, 'utf8');
}

// Fix all generated files
const libDir = path.join(__dirname, 'cs30/lib/coffeescript');
const files = fs.readdirSync(libDir).filter(f => f.endsWith('.js'));
files.forEach(file => {
  fixExportIIFE(path.join(libDir, file));
});
```

### Option 3: Restructure Source Files
Convert all instance properties to be initialized in constructors, but this would require modifying many files.

## Recommendation
For now, use Option 2 (post-processing) as a quick fix while working on a proper solution in the CoffeeScript compiler.
