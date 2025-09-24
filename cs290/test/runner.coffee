#!/usr/bin/env ../bin/coffee

###
CoffeeScript Solar Directive Test Runner
========================================
Tests Solar directive processing and compilation
###

fs = require 'fs'
path = require 'path'

# ANSI colors
green = '\x1B[0;32m'
red = '\x1B[0;31m'
yellow = '\x1B[0;33m'
bold = '\x1B[0;1m'
reset = '\x1B[0m'

# Test tracking
passed = 0
failed = 0
errors = []

# Simple test function (supports both syntaxes)
global.test = (name, fnOrExpected) ->
  try
    if typeof fnOrExpected is 'function'
      # Traditional: test "name", -> expect ...
      fnOrExpected()
    else
      # Ultra-simple: test "code", expected
      compiled = CoffeeScript.compile(name.trim())
      # Smart execution: use full function for variable assignments, expression extraction for literals
      if name.includes('=') or name.includes(';')
        # Contains assignments - need full function execution for variable scope
        result = eval(compiled)
      else
        # Simple literal/expression - can extract return expression safely
        match = compiled.match(/return\s+(.*);/)
        if match
          # Wrap in parentheses to ensure object literals are treated as expressions
          result = eval("(" + match[1] + ")")
        else
          result = eval("(#{compiled})()")
      eq result, fnOrExpected
    passed++
    console.log "#{green}✓#{reset} #{name}"
  catch e
    failed++
    errors.push {name, error: e.message}
    console.log "#{red}✗#{reset} #{name}: #{e.message}"

# Test helpers
global.eq = (actual, expected) ->
  # Deep equality check for objects and arrays
  deepEqual = (a, b) ->
    return true if a is b
    return false if a is null or b is null or a is undefined or b is undefined
    return false if typeof a isnt typeof b

    if Array.isArray(a) and Array.isArray(b)
      return false if a.length isnt b.length
      for i in [0...a.length]
        return false unless deepEqual(a[i], b[i])
      return true

    if typeof a is 'object' and typeof b is 'object'
      aKeys = Object.keys(a).sort()
      bKeys = Object.keys(b).sort()
      return false if aKeys.length isnt bKeys.length
      for key in aKeys
        return false if key not in bKeys
        return false unless deepEqual(a[key], b[key])
      return true

    a is b

  unless deepEqual(actual, expected)
    throw new Error "Expected #{expected}, got #{actual}"

global.ok = (value) ->
  throw new Error "Expected truthy value" unless value

# Test helper for clean Solar directive testing (supports both syntaxes)
global.expect = (code, expected) ->
  result = eval(CoffeeScript.compile(code.trim()))

  # Shortcut: expect code, result (auto .eq)
  if arguments.length is 2
    eq result, expected
  else
    # Fluent API: expect(code).eq(result)
    result: result
    eq: (expected) -> eq result, expected

# CoffeeScript reference for testing
global.CoffeeScript = require '../lib/coffeescript/index.js'

# Parse command line arguments
args = process.argv[2..]
targetDir = args[0] # e.g. 'es5' or 'test/es5' for subdirectory

# Main runner
console.log "#{bold}Solar Directive Test Suite#{reset}\n"

# Find test files based on arguments
testDir = __dirname
if targetDir
  # Run tests in specific subdirectory
  subDir = if targetDir.startsWith('test/') then targetDir else path.join(testDir, targetDir)
  unless fs.existsSync(subDir)
    console.log "#{red}Directory #{targetDir} not found#{reset}"
    process.exit 1

  testFiles = fs.readdirSync(subDir)
    .filter (f) -> f.endsWith('.test.coffee') or f.endsWith('.coffee')
    .sort()
    .map (f) -> path.join(subDir, f)

  console.log "Found #{testFiles.length} test file(s) in #{targetDir}\n"
else
  # Run tests in main directory only
  testFiles = fs.readdirSync(testDir)
    .filter (f) -> f.endsWith('.test.coffee')
    .sort()
    .map (f) -> path.join(testDir, f)

  console.log "Found #{testFiles.length} test file(s)\n"

# Enhanced reporting with per-file tracking
fileResults = []
totalTests = 0

# Run each test file
for file, fileIndex in testFiles
  fileName = path.basename(file)
  fileStartPassed = passed
  fileStartFailed = failed

  console.log "\n#{bold}[#{fileIndex + 1}/#{testFiles.length}] Running: #{fileName}#{reset}"

  code = fs.readFileSync(file, 'utf8')

  try
    # Use global CoffeeScript to compile and run test
    js = require('coffeescript').compile(code, bare: true, filename: file)
    eval(js)
  catch e
    failed++
    errors.push {name: fileName, error: e.message}
    console.log "#{red}✗ Test file error: #{e.message}#{reset}"

  # File summary
  filePassed = passed - fileStartPassed
  fileFailed = failed - fileStartFailed
  fileTotal = filePassed + fileFailed
  totalTests += fileTotal

  fileStatus = if fileFailed > 0 then red else green
  fileIcon = if fileFailed > 0 then "✗" else "✓"

  console.log "#{fileStatus}File: #{filePassed}/#{fileTotal} passed#{reset}"
  fileResults.push {fileName, filePassed, fileFailed, fileTotal, fileStatus, fileIcon}

# Overall summary
console.log "\n#{bold}Finals:#{reset}"
console.log "#{green}Passed: #{passed}#{reset}, #{if failed > 0 then red else green}Failed: #{failed}#{reset}"
console.log "#{green}Totals: #{totalTests} tests in #{testFiles.length} files#{reset}"

if failed > 0
  console.log "\n#{bold}Test Failures:#{reset}"
  for {name, error} in errors
    console.log "  #{red}✗ #{name}: #{error}#{reset}"
else
  console.log "#{green}All tests passed!#{reset}"

# File summary (left-aligned icons for quick scanning)
console.log "\n#{bold}Files:#{reset}"
for {fileName, filePassed, fileTotal, fileStatus, fileIcon} in fileResults
  console.log "#{fileStatus}#{fileIcon} #{fileName} (#{filePassed}/#{fileTotal})#{reset}"

process.exit(if failed > 0 then 1 else 0)
