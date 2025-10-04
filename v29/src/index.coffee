# Import statements - ES6 module syntax in CoffeeScript
import CoffeeScript from './coffeescript'

# Re-export helpers module
export * as helpers from './helpers'

# Default export
export default CoffeeScript

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
