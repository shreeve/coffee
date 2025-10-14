#!/usr/bin/env node

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

const sourceDir = './src';
const outputDir = './lib/coffeescript';
const cs270Path = '../cs270/bin/coffee';

// List of CoffeeScript source files to compile
const sourceFiles = [
  'helpers.coffee',
  'scope.litcoffee',
  'sourcemap.litcoffee', 
  'rewriter.coffee',
  'lexer.coffee',
  'coffeescript.coffee',
  'nodes.coffee',
  'index.coffee',
  'command.coffee',
  'browser.coffee',
  'register.coffee',
  'repl.coffee',
  'optparse.coffee',
  'cake.coffee',
  'es6.coffee'
];

console.log('Using CS270 to compile CS300 source files...\n');

// First, we need to temporarily modify the source files to remove ES6 syntax
// Create temporary modified versions
const tempDir = './temp_src';
if (!fs.existsSync(tempDir)) {
  fs.mkdirSync(tempDir);
}

for (const file of sourceFiles) {
  const sourcePath = path.join(sourceDir, file);
  const tempPath = path.join(tempDir, file);
  
  console.log(`Processing ${file}...`);
  
  let source = fs.readFileSync(sourcePath, 'utf8');
  
  // Convert ES6 imports to CommonJS
  source = source.replace(/^import\s+(\{[^}]+\})\s+from\s+['"]([^'"]+)['"]/gm, (match, imports, module) => {
    return `${imports} = require '${module.replace('.js', '')}'`;
  });
  source = source.replace(/^import\s+(\w+)\s+from\s+['"]([^'"]+)['"]/gm, (match, name, module) => {
    return `${name} = require '${module.replace('.js', '')}'`;
  });
  source = source.replace(/^import\s+\*\s+as\s+(\w+)\s+from\s+['"]([^'"]+)['"]/gm, (match, name, module) => {
    return `${name} = require '${module.replace('.js', '')}'`;
  });
  
  // Convert ES6 exports to CommonJS
  source = source.replace(/^export\s+default\s+(\w+)/gm, 'module.exports = $1');
  source = source.replace(/^export\s+class\s+(\w+)/gm, 'exports.$1 = class $1');
  source = source.replace(/^export\s+(\w+)\s*=/gm, 'exports.$1 =');
  source = source.replace(/^export\s+\{([^}]+)\}/gm, (match, exports) => {
    return exports.split(',').map(exp => {
      const parts = exp.trim().split(/\s+as\s+/);
      const localName = parts[0];
      const exportName = parts[1] || localName;
      return `exports.${exportName} = ${localName}`;
    }).join('\n');
  });
  
  fs.writeFileSync(tempPath, source, 'utf8');
}

// Now compile with CS270
for (const file of sourceFiles) {
  const tempPath = path.join(tempDir, file);
  const outputFile = file.replace(/\.(coffee|litcoffee)$/, '.js');
  const outputPath = path.join(outputDir, outputFile);
  
  console.log(`Compiling ${file}...`);
  
  try {
    const result = execSync(`${cs270Path} -c -b -o ${outputDir} ${tempPath}`, { encoding: 'utf8' });
    console.log(`  ✓ Compiled to ${outputFile}`);
  } catch (err) {
    console.error(`  ✗ Error compiling ${file}:`, err.message);
  }
}

// Clean up temp directory
fs.rmSync(tempDir, { recursive: true });

console.log('\nCompilation complete! Now converting to ES6...');

// Post-process to convert CommonJS to ES6
for (const file of sourceFiles) {
  const outputFile = file.replace(/\.(coffee|litcoffee)$/, '.js');
  const outputPath = path.join(outputDir, outputFile);
  
  if (fs.existsSync(outputPath)) {
    console.log(`Converting ${outputFile} to ES6...`);
    
    let js = fs.readFileSync(outputPath, 'utf8');
    
    // Remove the IIFE wrapper
    js = js.replace(/^\(function\(\) \{\n/, '');
    js = js.replace(/\n\}\).call\(this\);\n?$/, '');
    
    // Convert var to let/const (simple heuristic)
    js = js.replace(/^(\s*)var\s+/gm, '$1let ');
    
    // Convert require to import
    js = js.replace(/^(\s*)({[^}]+})\s*=\s*require\(['"]([^'"]+)['"]\);?$/gm, '$1import $2 from \'$3.js\';');
    js = js.replace(/^(\s*)(\w+)\s*=\s*require\(['"]([^'"]+)['"]\);?$/gm, '$1import $2 from \'$3.js\';');
    
    // Convert exports to export
    js = js.replace(/^(\s*)module\.exports\s*=\s*(\w+);?$/gm, '$1export default $2;');
    js = js.replace(/^(\s*)exports\.(\w+)\s*=\s*class\s+(\w+)/gm, '$1export class $3');
    js = js.replace(/^(\s*)exports\.(\w+)\s*=/gm, '$1export const $2 =');
    
    fs.writeFileSync(outputPath, js, 'utf8');
    console.log(`  ✓ Converted to ES6`);
  }
}

console.log('\nAll done!');
