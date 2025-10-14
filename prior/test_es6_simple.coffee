# Test ES6 output with const/let
x = 5
y = 10 
y = y + 1

double = (n) -> n * 2

class Test
  constructor: (@name) ->
    console.log "Creating Test: #{@name}"
    
result = double(x)
