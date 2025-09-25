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
      if name.includes('=') or name.includes(';') or name.includes('if ') or name.includes('unless ') or name.trim().startsWith('->') or name.trim().startsWith('=>') or name.includes(') ->')
        # Contains assignments, control flow, or functions - need full function execution for variable scope
        result = eval(compiled)
        # Special handling for assignment + function call tests
        if name.includes('=') and name.includes(';') and name.includes('(') and name.includes(')')
          # This is assignment + function call (like "func = (...) -> ...; func(...)")
          # The compiled result should be the return value of the final expression
          result = eval(compiled)
          # If result is still a function, it means the call didn't execute properly
          # Extract the final expression and try to execute it manually
          if typeof result is 'function' and name.includes('()')
            try
              # For arrow function assignments, try calling the result
              lastExpr = name.split(';').pop().trim()
              if lastExpr.includes('()')
                # This is a function call - the result should be the return value
                # If we got a function, try calling it
                result = result()
            catch callError
              # If calling fails, keep the function result
              result = result
        else if typeof result is 'function'
          # Determine argument count and call with test data
          if name.trim().startsWith('->') or name.trim().startsWith('=>')
            # No-parameter function or arrow function
            result = result()
          else if name.includes('(x) ->') or name.includes('(x) =>')
            result = result(42)  # Single parameter gets 42
          else if name.includes('(a, b) ->') or name.includes('(a, b) =>')
            result = result(3, 4)  # Two parameters get 3, 4 (sum = 7)
          else if name.includes('(n) ->') or name.includes('(n) =>')
            result = result(10)   # n parameter gets 10 (n * 2 = 20)
          else if name.includes('(s) ->') or name.includes('(s) =>')
            result = result('hello')  # s parameter gets 'hello'
          else
            # Default: try calling with no arguments
            result = result()
      else
        # Simple literal/expression - can extract return expression safely
        # Try multiline object pattern first, then fallback to simple pattern
        match = compiled.match(/return\s+(.*?);\s*\n\s*}\)\.call/s) || compiled.match(/return\s+(.*);/)
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
# Main runner
console.log "#{bold}Solar Directive Test Suite#{reset}\n"

# Collect test files from args (files or directories). If no args, default to this directory's .test.coffee
testDir = __dirname
cwd = process.cwd()
testFiles = []

getFilesFromDir = (dir) ->
  fs.readdirSync(dir)
    .filter (f) -> f.endsWith('.test.coffee') or f.endsWith('.coffee')
    .sort()
    .map (f) -> path.join(dir, f)

resolvePath = (p) ->
  return p if path.isAbsolute(p)
  cand1 = path.resolve(cwd, p)
  return cand1 if fs.existsSync(cand1)
  cand2 = path.resolve(testDir, p)
  return cand2

if args.length > 0
  for arg in args
    abs = resolvePath(arg)
    unless fs.existsSync(abs)
      console.log "#{red}Path not found: #{arg}#{reset}"
      continue
    stat = fs.statSync(abs)
    if stat.isDirectory()
      files = getFilesFromDir(abs)
      console.log "Found #{files.length} test file(s) in #{arg}\n"
      testFiles = testFiles.concat files
    else if stat.isFile()
      if abs.endsWith('.test.coffee') or abs.endsWith('.coffee')
        console.log "Found 1 test file: #{arg}\n"
        testFiles.push abs
      else
        console.log "#{yellow}Skipping non-test file: #{arg}#{reset}"
else
  files = getFilesFromDir(testDir)
  testFiles = testFiles.concat files
  console.log "Found #{files.length} test file(s)\n"

# Deduplicate & sort
seen = Object.create null
uniq = []
for f in testFiles when not seen[f]
  seen[f] = true
  uniq.push f
testFiles = uniq.sort()

if testFiles.length is 0
  console.log "#{red}No test files found#{reset}"
  process.exit 1

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
