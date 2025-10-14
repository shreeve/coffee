# Debug test for For loop
f = ->
  console.log "Before loop"
  result = for x in [1, 2, 3]
    console.log "In loop: #{x}"
    x * 2
  console.log "After loop"
  result

console.log "Result:", f()
