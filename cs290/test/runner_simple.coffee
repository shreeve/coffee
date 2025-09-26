#!/usr/bin/env ../bin/coffee

###
Simplified Test Runner for Solar CoffeeScript
###

fs = require 'fs'
path = require 'path'
CoffeeScript = require '../lib/coffeescript'

# ANSI colors
green = '\x1B[0;32m'
red = '\x1B[0;31m'
reset = '\x1B[0m'

# Test tracking
passed = 0
failed = 0

# Simple test function
global.test = (code, expected) ->
  try
    # Compile the code in bare mode
    compiled = CoffeeScript.compile code, bare: true
    
    # Extract the return value using a simple regex
    # Matches: return <value>;
    match = compiled.match(/^\s*return\s+(.*?);?\s*$/m)
    
    if match
      # Evaluate the extracted value
      actual = eval(match[1])
    else
      # No return statement, try to eval the whole thing
      actual = eval(compiled)
    
    # Compare
    if JSON.stringify(actual) == JSON.stringify(expected)
      passed++
      console.log "#{green}✓#{reset} #{code}"
    else
      failed++
      console.log "#{red}✗#{reset} #{code}: Expected #{JSON.stringify(expected)}, got #{JSON.stringify(actual)}"
  catch e
    failed++
    console.log "#{red}✗#{reset} #{code}: #{e.message}"

# Run test files
testFiles = process.argv[2..]
if testFiles.length == 0
  console.log "Usage: coffee runner_simple.coffee <test-file>..."
  process.exit(1)

for file in testFiles
  console.log "\nRunning #{file}:"
  require path.resolve(file)

# Summary
console.log "\n#{green}Passed: #{passed}#{reset}, #{red}Failed: #{failed}#{reset}"
process.exit(if failed > 0 then 1 else 0)
