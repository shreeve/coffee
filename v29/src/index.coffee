# Import statements - ES6 module syntax in CoffeeScript
import CoffeeScript from './coffeescript'
import * as helpersModule from './helpers'

# Default export
export default CoffeeScript

# Re-export helpers
export helpers = helpersModule

# Destructuring assignment from the imported module
{
  VERSION
  FILE_EXTENSIONS
  compile
  tokens
  nodes
  coffeeEval
  transpile
  patchStackTrace
} = CoffeeScript

# Re-exporting the destructured properties as named exports
export {
  VERSION
  FILE_EXTENSIONS
  compile
  tokens
  nodes
  coffeeEval
  transpile
  patchStackTrace
}
