#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function fixExportIIFE(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let modified = false;

  // Pattern to match: export (function() { ... }).call(this);
  const pattern = /export \(function\(\) \{([\s\S]*?)\n\}\)\.call\(this\);/g;

  content = content.replace(pattern, (match, body) => {
    modified = true;

    // Extract the return statement to find the class name
    const returnMatch = body.match(/return (\w+);/);
    if (!returnMatch) {
      console.warn(`Warning: Could not find return statement in IIFE in ${filePath}`);
      return match;
    }

    const className = returnMatch[1];

    // Remove the return statement from the body
    const cleanBody = body.replace(/\s*return \w+;\s*$/, '');

    // Find where the class definition ends (before prototype assignments)
    // Look for the class closing brace
    const classMatch = cleanBody.match(/(class \w+[^{]*\{[\s\S]*?\n\s*\})/);

    if (classMatch) {
      const classDefinition = classMatch[1];
      const afterClass = cleanBody.substring(classMatch.index + classMatch[0].length);

      // Return the class with export, followed by prototype assignments
      return `export ${classDefinition}${afterClass}`;
    }

    // Fallback: just export the class and include everything
    return `export ${cleanBody.trim()}`;
  });

  if (modified) {
    fs.writeFileSync(filePath, content, 'utf8');
    return true;
  }
  return false;
}

// Get directory from command line or use default
const libDir = process.argv[2] || path.join(__dirname, 'cs30/lib/coffeescript');

console.log(`Fixing export IIFEs in: ${libDir}`);

// Process all .js files
const files = fs.readdirSync(libDir).filter(f => f.endsWith('.js'));
let fixedCount = 0;

files.forEach(file => {
  const filePath = path.join(libDir, file);
  if (fixExportIIFE(filePath)) {
    console.log(`✓ Fixed: ${file}`);
    fixedCount++;
  }
});

console.log(`\nFixed ${fixedCount} files with export IIFE issues.`);
