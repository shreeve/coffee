#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function fixRefScope(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let modified = false;

  // Fix the cache method's ref scoping issue
  content = content.replace(
    /cache\(o, level, shouldCache\) \{([^}]*?)if \(complex\) \{\s*let ref = /gm,
    (match, beforeIf) => {
      modified = true;
      return `cache(o, level, shouldCache) {${beforeIf}let ref;\n    if (complex) {\n      ref = `;
    }
  );

  // Fix any other similar patterns where ref is declared in if but used in else
  content = content.replace(
    /(\s+)if \(([^)]+)\) \{\s*let (\w+) = ([^;]+);([^}]*)\} else \{\s*\3 = /gm,
    (match, indent, condition, varName, value, ifBody) => {
      modified = true;
      return `${indent}let ${varName};\n${indent}if (${condition}) {\n${indent}  ${varName} = ${value};${ifBody}} else {\n${indent}  ${varName} = `;
    }
  );

  // Also handle 'const' variables that need to be 'let' when reassigned
  content = content.replace(
    /(\s+)if \(([^)]+)\) \{\s*const (\w+) = ([^;]+);([^}]*)\} else \{\s*\3 = /gm,
    (match, indent, condition, varName, value, ifBody) => {
      modified = true;
      return `${indent}let ${varName};\n${indent}if (${condition}) {\n${indent}  ${varName} = ${value};${ifBody}} else {\n${indent}  ${varName} = `;
    }
  );

  if (modified) {
    fs.writeFileSync(filePath, content, 'utf8');
    return true;
  }
  return false;
}

// Get directory from command line or use default
const libDir = process.argv[2] || path.join(__dirname, 'cs30/lib/coffeescript');

console.log(`Fixing ref scope issues in: ${libDir}`);

// Process all .js files
const files = fs.readdirSync(libDir).filter(f => f.endsWith('.js'));
let fixedCount = 0;

files.forEach(file => {
  const filePath = path.join(libDir, file);
  if (fixRefScope(filePath)) {
    console.log(`✓ Fixed: ${file}`);
    fixedCount++;
  }
});

console.log(`\nFixed ${fixedCount} files with ref scope issues.`);
