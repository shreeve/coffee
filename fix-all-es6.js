#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function fixAllES6Issues(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  const originalContent = content;

  // Fix 1: TERROR duplicate declaration
  // If we see const TERROR multiple times, keep only the first
  const terrorMatches = content.match(/const TERROR = /g);
  if (terrorMatches && terrorMatches.length > 1) {
    // Replace subsequent declarations with reassignments
    let firstFound = false;
    content = content.replace(/const TERROR = /g, (match) => {
      if (!firstFound) {
        firstFound = true;
        return match;
      }
      return 'TERROR = ';
    });
  }

  // Fix 2: 'results' not defined
  // Look for patterns where results is used without declaration
  // Common pattern: results = [] later followed by results.push
  if (!content.includes('let results') && !content.includes('const results') && content.includes('results')) {
    // Find the first usage of results =
    const resultsMatch = content.match(/^(\s*)results = /m);
    if (resultsMatch) {
      const indent = resultsMatch[1];
      // Add declaration at the same indentation level
      content = content.replace(/^(\s*)results = /m, `$1let results = `);
    }
  }

  // Fix 3: General undeclared variable pattern
  // Look for variable = value at start of line without let/const
  const lines = content.split('\n');
  const declaredVars = new Set();
  const processedLines = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Track declared variables
    const declareMatch = line.match(/^\s*(?:let|const|var)\s+(\w+)/);
    if (declareMatch) {
      declaredVars.add(declareMatch[1]);
    }

    // Check for undeclared assignments (simple pattern)
    const assignMatch = line.match(/^(\s*)(\w+) = /);
    if (assignMatch && !line.includes('const') && !line.includes('let') && !line.includes('var')) {
      const indent = assignMatch[1];
      const varName = assignMatch[2];

      // Skip if already declared or if it's a property/method
      if (!declaredVars.has(varName) &&
          !line.includes('.') &&
          !line.includes('this.') &&
          varName !== 'exports' &&
          varName !== 'module') {
        // Add let declaration
        processedLines.push(line.replace(`${varName} = `, `let ${varName} = `));
        declaredVars.add(varName);
        continue;
      }
    }

    processedLines.push(line);
  }

  if (processedLines.join('\n') !== content) {
    content = processedLines.join('\n');
  }

  // Write back if changed
  if (content !== originalContent) {
    fs.writeFileSync(filePath, content, 'utf8');
    return true;
  }
  return false;
}

// Get directory from command line or use default
const libDir = process.argv[2] || path.join(__dirname, 'cs30/lib/coffeescript');

console.log(`Fixing all ES6 issues in: ${libDir}`);

// Process all .js files
const files = fs.readdirSync(libDir).filter(f => f.endsWith('.js'));
let fixedCount = 0;

files.forEach(file => {
  const filePath = path.join(libDir, file);
  if (fixAllES6Issues(filePath)) {
    console.log(`✓ Fixed: ${file}`);
    fixedCount++;
  }
});

console.log(`\nFixed ${fixedCount} files.`);
