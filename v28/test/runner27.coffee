#!/usr/bin/env ../bin/coffee

# ==============================================================================
# runner.coffee - A simple, straightforward test runner that just works
# ==============================================================================

fs = require 'fs'
path = require 'path'
CoffeeScript = require '../../v27/lib/coffeescript'

# ANSI colors
green = '\x1B[0;32m'
red = '\x1B[0;31m'
bold = '\x1B[0;1m'
reset = '\x1B[0m'

# Test tracking
passed = 0
failed = 0
totalFiles = 0

# Test that code should fail to compile
global.fail = (code) ->
  try
    # Try to compile the CoffeeScript code
    CoffeeScript.compile code, bare: true
    # If it compiles without error, the test fails
    failed++
    displayCode = code.replace(/\n/g, '\n  ')
    console.log "#{red}✗#{reset} #{displayCode}"
    console.log "    Expected: compilation error"
    console.log "    Got:      compiled successfully"
  catch e
    # If it throws an error, the test passes (as expected)
    passed++
    displayCode = code.replace(/\n/g, '\n  ')
    console.log "#{green}✓#{reset} #{displayCode} (expected to fail)"
  return

# Test that code compiles to specific JavaScript
global.code = (coffeeCode, expectedJs) ->
  try
    # Compile the CoffeeScript code
    compiled = CoffeeScript.compile coffeeCode, bare: true
    # Normalize whitespace for comparison
    actualJs = compiled.trim()
    expectedJs = expectedJs.trim()

    if actualJs == expectedJs
      passed++
      displayCode = coffeeCode.replace(/\n/g, '\n  ')
      console.log "#{green}✓#{reset} #{displayCode} → #{expectedJs}"
    else
      failed++
      displayCode = coffeeCode.replace(/\n/g, '\n  ')
      console.log "#{red}✗#{reset} #{displayCode}"
      console.log "    Expected JS: #{expectedJs}"
      console.log "    Got JS:      #{actualJs}"
  catch e
    failed++
    displayCode = coffeeCode.replace(/\n/g, '\n  ')
    console.log "#{red}✗#{reset} #{displayCode}"
    console.log "    Compilation Error: #{e.message}"
  return

# Simple test function: test "code", expected_value
global.test = (code, expected) ->
  try
    # Use CoffeeScript.eval with a fresh sandbox for isolation
    # This prevents variable pollution between tests
    vm = require 'vm'
    sandbox = vm.createContext({
      console: console
      require: require
      global: global
      process: process
      Buffer: Buffer
      Math: Math
      Date: Date
      Array: Array
      Object: Object
      String: String
      Number: Number
      Boolean: Boolean
      RegExp: RegExp
      Error: Error
      JSON: JSON
    })
    actual = CoffeeScript.eval code, {sandbox}

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

console.log "#{bold}CoffeeScript #{CoffeeScript.VERSION} Test Runner#{reset}"

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

  # Read the test file and compile it with v27 CoffeeScript
  testCode = fs.readFileSync(file, 'utf8')
  try
    # Compile the test file with v27
    compiledTest = CoffeeScript.compile testCode,
      filename: file
      bare: true

    # Evaluate the compiled test in the current context
    # This ensures test(), fail(), and code() are available
    eval compiledTest
  catch e
    console.log "#{red}Error compiling/running test file: #{e.message}#{reset}"
    if e.location
      console.log "  at line #{e.location.first_line + 1}, column #{e.location.first_column + 1}"

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
