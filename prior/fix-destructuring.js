#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function fixDestructuring(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let modified = false;

  // Fix destructuring assignments without declaration
  // Pattern: [var1, var2] = expression; (missing let/const)
  content = content.replace(
    /^(\s*)\[(\w+), (\w+)\] = /gm,
    (match, indent, var1, var2) => {
      // Check if this is already inside a declaration
      // (sometimes the pattern might already be correct)
      if (!match.includes('const') && !match.includes('let')) {
        modified = true;
        return `${indent}const [${var1}, ${var2}] = `;
      }
      return match;
    }
  );

  // Also handle single destructuring
  content = content.replace(
    /^(\s*)\[(\w+)\] = /gm,
    (match, indent, var1) => {
      if (!match.includes('const') && !match.includes('let')) {
        modified = true;
        return `${indent}const [${var1}] = `;
      }
      return match;
    }
  );

  // Handle object destructuring
  content = content.replace(
    /^(\s*)\{([^}]+)\} = /gm,
    (match, indent, vars) => {
      if (!match.includes('const') && !match.includes('let')) {
        modified = true;
        return `${indent}const {${vars}} = `;
      }
      return match;
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

console.log(`Fixing destructuring assignments in: ${libDir}`);

// Process all .js files
const files = fs.readdirSync(libDir).filter(f => f.endsWith('.js'));
let fixedCount = 0;

files.forEach(file => {
  const filePath = path.join(libDir, file);
  if (fixDestructuring(filePath)) {
    console.log(`✓ Fixed: ${file}`);
    fixedCount++;
  }
});

console.log(`\nFixed ${fixedCount} files with destructuring issues.`);
