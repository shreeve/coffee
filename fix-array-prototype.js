#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function fixArrayPrototype(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let modified = false;

  // Fix the broken Array.prototype.some pattern
  // This pattern is invalid: (ref = Array.prototype.some) != null ? ref : ...
  content = content.replace(
    /export const (\w+) = \(ref = ([\w.]+)\) != null \? ref : /g,
    (match, varName, prototype) => {
      modified = true;
      return `export const ${varName} = ${prototype} != null ? ${prototype} : `;
    }
  );

  // Fix similar patterns with different variable names
  content = content.replace(
    /const (\w+) = \((\w+) = ([\w.]+)\) != null \? \2 : /g,
    (match, varName, tempVar, prototype) => {
      modified = true;
      return `const ${varName} = ${prototype} != null ? ${prototype} : `;
    }
  );

  // Also fix any ref1, ref2, etc. patterns
  content = content.replace(
    /let (\w+) = \((\w+) = ([\w.\[\]]+)\) != null \? \2 : /g,
    (match, varName, tempVar, expression) => {
      modified = true;
      return `let ${varName} = ${expression} != null ? ${expression} : `;
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

console.log(`Fixing Array.prototype patterns in: ${libDir}`);

// Process all .js files
const files = fs.readdirSync(libDir).filter(f => f.endsWith('.js'));
let fixedCount = 0;

files.forEach(file => {
  const filePath = path.join(libDir, file);
  if (fixArrayPrototype(filePath)) {
    console.log(`✓ Fixed: ${file}`);
    fixedCount++;
  }
});

console.log(`\nFixed ${fixedCount} files with Array.prototype issues.`);
