# Pure ES6 CoffeeScript Compiler - Platform Agnostic
import CoffeeScript from './coffeescript'
import * as helpers from './helpers'

export default CoffeeScript

# Export helpers separately since it's not re-exported from coffeescript
export {helpers}

# Export only the core compiler methods as named exports
export {
  VERSION
  FILE_EXTENSIONS
  compile
  tokens
  nodes
  coffeeEval
  transpile
  patchStackTrace
} = CoffeeScript
