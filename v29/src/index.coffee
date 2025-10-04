# Import statements - ES6 module syntax in CoffeeScript
import CoffeeScript from './coffeescript'
import * as helpersModule from './helpers'

# Default export
export default CoffeeScript

# Re-export helpers
export helpers = helpersModule

# Re-export specific properties from CoffeeScript
export VERSION = CoffeeScript.VERSION
export FILE_EXTENSIONS = CoffeeScript.FILE_EXTENSIONS
export compile = CoffeeScript.compile
export tokens = CoffeeScript.tokens
export nodes = CoffeeScript.nodes
export coffeeEval = CoffeeScript.coffeeEval
export patchStackTrace = CoffeeScript.patchStackTrace
