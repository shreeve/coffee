#!/usr/bin/env node

import CoffeeScript from './lib/coffeescript/index.js';
import fs from 'fs';
import path from 'path';

const sourceDir = './src';
const outputDir = './lib/coffeescript';

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

console.log('Compiling CS300 source files...\n');

for (const file of sourceFiles) {
  const sourcePath = path.join(sourceDir, file);
  const outputFile = file.replace(/\.(coffee|litcoffee)$/, '.js');
  const outputPath = path.join(outputDir, outputFile);

  console.log(`Compiling ${file}...`);

  try {
    const source = fs.readFileSync(sourcePath, 'utf8');
    const compiled = CoffeeScript.compile(source, {
      filename: sourcePath,
      bare: true,
      header: false
    });

    fs.writeFileSync(outputPath, compiled, 'utf8');
    console.log(`  ✓ Compiled to ${outputFile}`);
  } catch (err) {
    console.error(`  ✗ Error compiling ${file}:`, err.message);
    console.error(err.stack);
  }
}

console.log('\nCompilation complete!');
