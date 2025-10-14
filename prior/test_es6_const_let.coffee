# Test ES6 const/let determination

# Should be const (never reassigned)
x = 42
y = "hello"

# Should be let (reassigned)
counter = 0
counter = counter + 1

# Should be const (function)
double = (n) -> n * 2

# Should be const (class)
class Animal
  constructor: (@name) ->

# Should be let (conditional reassignment)
result = null
if Math.random() > 0.5
  result = "yes"
else
  result = "no"

# Export test
export myFunc = -> console.log "test"

# Import test  
import {something} from './lib'
