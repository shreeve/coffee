# Pure ES6 CoffeeScript Compiler - Platform Agnostic
import CoffeeScript from './coffeescript'

export default CoffeeScript

# Export only the core compiler methods as named exports
export {
  VERSION
  FILE_EXTENSIONS
  helpers
  compile
  tokens
  nodes
  coffeeEval
  transpile
  patchStackTrace
} = CoffeeScript
