# Node.js Implementation
import * as CoffeeScript from './coffeescript'
import fs from 'fs'
import vm from 'vm'
import path from 'path'

helpers       = CoffeeScript.helpers

# The `compile` method is directly available from coffeescript module
# No need for transpilation support

# Compile and execute a string of CoffeeScript (on the server), correctly
# setting `__filename`, `__dirname`, and relative `require()`.
CoffeeScript.run = (code, options = {}) ->
  mainModule = require.main

  # Set the filename.
  mainModule.filename = process.argv[1] =
    if options.filename then fs.realpathSync(options.filename) else helpers.anonymousFileName()

  # Clear the module cache.
  mainModule.moduleCache and= {}

  # Assign paths for node_modules loading
  dir = if options.filename?
    path.dirname fs.realpathSync options.filename
  else
    fs.realpathSync '.'
  mainModule.paths = require('module')._nodeModulePaths dir

  # Save the options for compiling child imports.
  mainModule.options = options

  options.filename = mainModule.filename
  options.inlineMap = true

  # Compile.
  answer = CoffeeScript.compile code, options
  code = answer.js ? answer

  mainModule._compile code, mainModule.filename

# Compile and evaluate a string of CoffeeScript (in a Node.js-like environment).
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
    # define module/require only if they chose not to specify their own
    unless sandbox isnt global or sandbox.module or sandbox.require
      Module = require 'module'
      sandbox.module  = _module  = new Module(options.modulename || 'eval')
      sandbox.require = _require = (path) ->  Module._load path, _module, true
      _module.filename = sandbox.__filename
      for r in Object.getOwnPropertyNames require when r not in ['paths', 'arguments', 'caller']
        _require[r] = require[r]
      # use the same hack node uses for module resolution
      _require.paths = _module.paths = Module._nodeModulePaths process.cwd()
      _require.resolve = (request) -> Module._resolveFilename request, _module
  o = {}
  o[k] = v for own k, v of options
  o.bare = on # ensure return value
  js = CoffeeScript.compile code, o
  if sandbox is global
    vm.runInThisContext js
  else
    vm.runInContext js, sandbox


# Throw error with deprecation warning when depending upon implicit `require.extensions` registration
if require.extensions
  for ext in CoffeeScript.FILE_EXTENSIONS then do (ext) ->
    require.extensions[ext] ?= ->
      throw new Error """
      ES6 modules do not support runtime .coffee file loading. Please compile .coffee files to .js first.
      """

CoffeeScript._compileRawFileContent = (raw, filename, options = {}) ->

  # Strip the Unicode byte order mark, if this file begins with one.
  stripped = if raw.charCodeAt(0) is 0xFEFF then raw.substring 1 else raw

  options = Object.assign {}, options,
    filename: filename
    literate: helpers.isLiterate filename
    sourceFiles: [filename]

  try
    answer = CoffeeScript.compile stripped, options
  catch err
    # As the filename and code of a dynamically loaded file will be different
    # from the original file compiled with CoffeeScript.run, add that
    # information to error so it can be pretty-printed later.
    throw helpers.updateSyntaxError err, stripped, filename

  answer

CoffeeScript._compileFile = (filename, options = {}) ->
  raw = fs.readFileSync filename, 'utf8'

  CoffeeScript._compileRawFileContent raw, filename, options

export default CoffeeScript

# Named exports for backwards compatibility and better tree-shaking
export {
  VERSION,
  FILE_EXTENSIONS,
  helpers,
  registerCompiled,
  compile,
  tokens,
  nodes,
  patchStackTrace
} from './coffeescript'

# Export the modified functions from this module
export {CoffeeScript.eval as eval}
export {CoffeeScript.run as run}
export {CoffeeScript._compileRawFileContent as _compileRawFileContent}
export {CoffeeScript._compileFile as _compileFile}
