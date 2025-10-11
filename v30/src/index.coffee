# index.coffee - ES6 version
import * as CoffeeScript from './coffeescript'
import fs from 'fs'
import vm from 'vm'

# Compile CoffeeScript code to JavaScript
export compile = CoffeeScript.compile

# Compile and run CoffeeScript code
export run = (code, options = {}) ->
  compiled = CoffeeScript.compile code, {
    bare: true
    ...options
  }

  vm.runInThisContext compiled.js ? compiled

# Evaluate CoffeeScript in a sandbox context
export evalCode = (code, options = {}) ->
  return unless code = code.trim()

  # Create or use provided sandbox
  sandbox = options.sandbox ? global

  # Compile with bare:true for eval
  compiled = CoffeeScript.compile code, {
    bare: true
    ...options
  }

  # Run in appropriate context
  if sandbox is global
    vm.runInThisContext compiled
  else
    vm.runInContext compiled, vm.createContext(sandbox)

# Compile a file
export compileFile = (filename, options = {}) ->
  source = fs.readFileSync filename, 'utf8'
  CoffeeScript.compile source, {
    filename
    ...options
  }

# Run a file
export runFile = (filename, options = {}) ->
  compiled = compileFile filename, options
  vm.runInThisContext compiled.js ? compiled

# Re-export everything else from coffeescript
export * from './coffeescript'
export { default } from './coffeescript'
