#!/usr/bin/env ../bin/coffee

###
Clean Test Runner for Solar CoffeeScript
=========================================
Simple, straightforward test runner that just works
###

fs = require 'fs'
path = require 'path'
CoffeeScript = require '../lib/coffeescript'

# ANSI colors
green = '\x1B[0;32m'
red = '\x1B[0;31m'
bold = '\x1B[0;1m'
reset = '\x1B[0m'

# Test tracking
passed = 0
failed = 0
totalFiles = 0

# Simple test function: test "code", expected_value
global.test = (code, expected) ->
  try
    # Compile the CoffeeScript code in bare mode
    compiled = CoffeeScript.compile code, bare: true
    
    # For if/else and other control flow, we need to evaluate the whole thing
    # Wrap in a function and call it
    if compiled.includes('if (') or compiled.includes('try {') or compiled.includes('switch (')
      actual = eval("(function() { #{compiled} })()")
    else
      # Extract return value: "return <expr>;"
      match = compiled.match(/return\s+(.*);/)
      unless match
        throw new Error "No return statement found in compiled output"
      
      # Evaluate the expression
      actual = eval(match[1])
    
    # Deep equality comparison
    actualStr = JSON.stringify(actual)
    expectedStr = JSON.stringify(expected)
    
    if actualStr == expectedStr
      passed++
      console.log "#{green}✓#{reset} #{code}"
    else
      failed++
      console.log "#{red}✗#{reset} #{code}"
      console.log "    Expected: #{expectedStr}"
      console.log "    Got:      #{actualStr}"
  catch e
    failed++
    console.log "#{red}✗#{reset} #{code}"
    console.log "    Error: #{e.message}"

# Process command line arguments
args = process.argv[2..]
if args.length == 0
  console.log "Usage: coffee runner_clean.coffee <test-file-or-directory>..."
  process.exit(1)

console.log "#{bold}Solar CoffeeScript Test Runner#{reset}\n"

# Find all test files
testFiles = []
for arg in args
  stat = fs.statSync(arg)
  if stat.isDirectory()
    # Find all .coffee files in directory
    files = fs.readdirSync(arg)
    for file in files when file.endsWith('.coffee')
      testFiles.push path.join(arg, file)
  else if arg.endsWith('.coffee')
    testFiles.push arg

# Run each test file
for file in testFiles
  totalFiles++
  console.log "\n#{bold}[#{totalFiles}/#{testFiles.length}] #{path.basename(file)}#{reset}"
  
  # Reset test counts for this file
  filePassed = passed
  fileFailed = failed
  
  # Load and run the test file
  require path.resolve(file)
  
  # Show file summary
  filePassCount = passed - filePassed
  fileFailCount = failed - fileFailed
  if fileFailCount == 0
    console.log "#{green}File: #{filePassCount} passed#{reset}"
  else
    console.log "#{red}File: #{filePassCount} passed, #{fileFailCount} failed#{reset}"

# Final summary
console.log "\n#{bold}Summary:#{reset}"
console.log "#{green}Passed: #{passed}#{reset}"
console.log "#{red}Failed: #{failed}#{reset}"
total = passed + failed
if total > 0
  percentage = Math.round(passed * 100 / total)
  console.log "Success rate: #{percentage}%"

# Exit with error if any tests failed
process.exit(if failed > 0 then 1 else 0)
