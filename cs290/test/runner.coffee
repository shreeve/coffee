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

# Simple test function
global.test = (name, fn) ->
  try
    fn()
    passed++
    console.log "#{green}✓#{reset} #{name}"
  catch e
    failed++
    errors.push {name, error: e.message}
    console.log "#{red}✗#{reset} #{name}: #{e.message}"

# Test helpers
global.eq = (actual, expected) ->
  if actual isnt expected
    throw new Error "Expected #{expected}, got #{actual}"

global.ok = (value) ->
  throw new Error "Expected truthy value" unless value

# Test helper for clean Solar directive testing
global.expect = (code) ->
  result: eval(CoffeeScript.compile(code.trim()))
  eq: (expected) -> eq @result, expected

# CoffeeScript reference for testing
global.CoffeeScript = require '../lib/coffeescript/index.js'

# Main runner
console.log "#{bold}Solar Directive Test Suite#{reset}\n"

# Find and run all test files
testDir = __dirname
testFiles = fs.readdirSync(testDir)
  .filter (f) -> f.endsWith('.test.coffee')
  .sort()
  .map (f) -> path.join(testDir, f)

console.log "Found #{testFiles.length} test file(s)\n"

# Run each test file
for file in testFiles
  console.log "#{bold}Running: #{path.basename(file)}#{reset}"
  code = fs.readFileSync(file, 'utf8')

  try
    # Use global CoffeeScript to compile and run test
    js = require('coffeescript').compile(code, bare: true, filename: file)
    eval(js)
  catch e
    failed++
    errors.push {name: file, error: e.message}
    console.log "#{red}Test file error: #{e.message}#{reset}"

# Summary
console.log "\n#{bold}Results:#{reset}"
console.log "#{green}Passed: #{passed}#{reset}"
if failed > 0
  console.log "#{red}Failed: #{failed}#{reset}"
  console.log "\n#{bold}Errors:#{reset}"
  for {name, error} in errors
    console.log "  #{red}#{path.basename(name)}:#{reset} #{error}"
else
  console.log "#{green}All tests passed!#{reset}"

process.exit(if failed > 0 then 1 else 0)
