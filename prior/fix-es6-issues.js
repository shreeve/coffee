#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function fixES6Issues(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let modified = false;

  // Fix 1: Variable scoping issues with if/else blocks
  // Pattern: let/const declared in if block but used in else block
  const scopingPattern = /(\s+)if \([^)]+\) \{\n(\s+)(?:let|const) (\w+) = ([^;]+);([\s\S]*?)\n\1\} else \{\n\2(\3) = /g;

  content = content.replace(scopingPattern, (match, indent1, indent2, varName, initialValue, ifBody, assignment) => {
    modified = true;
    // Move the declaration before the if statement
    return `${indent1}let ${varName};\n${indent1}if (${match.match(/if \(([^)]+)\)/)[1]}) {\n${indent2}${varName} = ${initialValue};${ifBody}\n${indent1}} else {\n${indent2}${varName} = `;
  });

  // Fix 2: More general case - find variables used in else that were declared in if
  // This is a bit more complex, so let's do a targeted fix for the cache method
  if (content.includes('cache(o, level, shouldCache)')) {
    content = content.replace(
      /cache\(o, level, shouldCache\) \{([\s\S]*?)if \(complex\) \{([\s\S]*?)let ref = ([\s\S]*?)\} else \{([\s\S]*?)ref = /,
      (match, before, ifContent, refInit, elseStart) => {
        modified = true;
        return `cache(o, level, shouldCache) {${before}let ref;\n    if (complex) {${ifContent}ref = ${refInit}} else {${elseStart}ref = `;
      }
    );
  }

  // Fix 3: Variables that should be declared at function scope
  // Look for patterns where a variable is assigned in both if and else branches
  const lines = content.split('\n');
  const processedLines = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Check for else blocks with assignments to undeclared variables
    if (line.match(/^\s*} else \{$/)) {
      // Look ahead for variable assignments
      let j = i + 1;
      while (j < lines.length && !lines[j].match(/^\s*\}/)) {
        const assignMatch = lines[j].match(/^(\s+)(\w+) = /);
        if (assignMatch) {
          const indent = assignMatch[1];
          const varName = assignMatch[2];

          // Check if this variable was declared in the preceding if block
          let k = i - 1;
          let foundInIf = false;
          while (k >= 0 && !lines[k].match(/^\s*if \(/)) {
            if (lines[k].includes(`let ${varName}`) || lines[k].includes(`const ${varName}`)) {
              foundInIf = true;
              break;
            }
            k--;
          }

          if (foundInIf) {
            // Find the if statement and add declaration before it
            while (k >= 0 && !lines[k].match(/^\s*if \(/)) k--;
            if (k >= 0) {
              // Insert declaration before if statement
              const ifIndent = lines[k].match(/^(\s*)/)[1];
              processedLines.push(`${ifIndent}let ${varName};`);
              modified = true;

              // Update the let/const in if block to just assignment
              for (let m = k; m < i; m++) {
                lines[m] = lines[m].replace(new RegExp(`(let|const) ${varName} = `), `${varName} = `);
              }
            }
          }
        }
        j++;
      }
    }

    processedLines.push(line);
  }

  if (modified) {
    content = processedLines.join('\n');
    fs.writeFileSync(filePath, content, 'utf8');
    return true;
  }
  return false;
}

// Get directory from command line or use default
const libDir = process.argv[2] || path.join(__dirname, 'cs30/lib/coffeescript');

console.log(`Fixing ES6 issues in: ${libDir}`);

// Process all .js files
const files = fs.readdirSync(libDir).filter(f => f.endsWith('.js'));
let fixedCount = 0;

files.forEach(file => {
  const filePath = path.join(libDir, file);
  if (fixES6Issues(filePath)) {
    console.log(`✓ Fixed: ${file}`);
    fixedCount++;
  }
});

console.log(`\nFixed ${fixedCount} files with ES6 issues.`);
