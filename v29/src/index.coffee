# Import statements - ES6 module syntax in CoffeeScript
import CoffeeScript from './coffeescript'
import * as helpersModule from './helpers'
import fs from 'fs'
import vm from 'vm'
import path from 'path'
import Module from 'module'

# Compile and execute a string of CoffeeScript (on the server), correctly
# setting `__filename`, `__dirname`.
CoffeeScript.run = (code, options = {}) ->
  # For ES6 modules, we can't use require.main, so we'll use a simpler approach
  # Set the filename.
  filename = if options.filename then fs.realpathSync(options.filename) else helpersModule.anonymousFileName()

  # Update process.argv if needed
  process.argv[1] = filename if options.filename

  # Set compilation options
  options.filename = filename
  options.inlineMap = true
  options.bare = true  # Don't wrap in an IIFE for run mode

  # Compile.
  answer = CoffeeScript.compile code, options
  code = answer.js ? answer

  # Evaluate the compiled code
  # In ES6 modules, we'll use vm.runInThisContext for now
  vm.runInThisContext code, {filename}

# Compile and evaluate a string of CoffeeScript (in a Node.js-like environment).
# The CoffeeScript REPL uses this to run the input.
CoffeeScript.eval = (code, options = {}) ->
  return unless code = code.trim()
  createContext = vm.Script.createContext ? vm.createContext

  isContext = vm.isContext ? (ctx) ->
    options.sandbox instanceof createContext().constructor

  if createContext
    if options.sandbox?
      if isContext options.sandbox
        sandbox = options.sandbox
      else
        sandbox = createContext()
        sandbox[k] = v for own k, v of options.sandbox
      sandbox.global = sandbox.root = sandbox.GLOBAL = sandbox
    else
      sandbox = global
    sandbox.__filename = options.filename || 'eval'
    sandbox.__dirname  = path.dirname sandbox.__filename
    # For ES6 modules, skip module/require setup since it's complex and not critical for eval
  o = {}
  o[k] = v for own k, v of options
  o.bare = on # ensure return value
  js = CoffeeScript.compile code, o
  if sandbox is global
    vm.runInThisContext js
  else
    vm.runInContext js, sandbox

CoffeeScript.register = ->
  # ES6 modules don't support dynamic require, so we'll throw a helpful error
  throw new Error 'CoffeeScript.register() is not yet supported in ES6 module mode. Please use CommonJS mode for register functionality.'

# Default export
export default CoffeeScript

# Re-export helpers
export helpers = helpersModule

# Re-export individual properties from CoffeeScript
export VERSION = CoffeeScript.VERSION
export FILE_EXTENSIONS = CoffeeScript.FILE_EXTENSIONS
export compile = CoffeeScript.compile
export tokens = CoffeeScript.tokens
export nodes = CoffeeScript.nodes
export patchStackTrace = CoffeeScript.patchStackTrace
export registerCompiled = CoffeeScript.registerCompiled
export run = CoffeeScript.run
export evaluate = CoffeeScript.eval
export register = CoffeeScript.register
