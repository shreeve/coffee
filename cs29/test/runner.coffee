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
    # For testing, we need the value of expressions, so compile with returns
    compiled = CoffeeScript.compile code, bare: true, makeReturn: true

    # Wrap everything in a function and call it
    # This handles all cases: returns, control flow, assignments, etc.
    actual = eval("(function() { #{compiled} })()")

    # Handle function expected values (for validation tests like Object.defineProperty)
    if typeof expected == 'function'
      # The expected function validates the actual result
      testPassed = expected.call(null, actual)
    else
      # Deep equality comparison
      # Handle circular references (like global/this)
      try
        actualStr = JSON.stringify(actual)
        expectedStr = JSON.stringify(expected)
      catch e
        # If JSON.stringify fails (circular reference), compare directly
        # Normalize whitespace for comparison
        actualStr = String(actual).trim()
        expectedStr = String(expected).trim()

      # For string comparisons with functions, strip ALL whitespace for comparison
      # This handles indentation differences in StringInterpolation tests
      if typeof actual == 'string' and actual.includes('function')
        # Remove ALL whitespace for comparison
        actualStr = actualStr.replace(/\s+/g, '')
        expectedStr = expectedStr.replace(/\s+/g, '')

      testPassed = actualStr == expectedStr

    if testPassed
      passed++
      # Indent continuation lines for multi-line code display
      displayCode = code.replace(/\n/g, '\n  ')
      console.log "#{green}✓#{reset} #{displayCode}"
    else
      failed++
      # Indent continuation lines for multi-line code display
      displayCode = code.replace(/\n/g, '\n  ')
      console.log "#{red}✗#{reset} #{displayCode}"
      if typeof expected != 'function'
        console.log "    Expected: #{expectedStr}"
        console.log "    Got:      #{actualStr}"
      else
        console.log "    Validation function returned false"
  catch e
    failed++
    # Indent continuation lines for multi-line code display
    displayCode = code.replace(/\n/g, '\n  ')
    console.log "#{red}✗#{reset} #{displayCode}"
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
