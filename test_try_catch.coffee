# Test try/catch variable promotion
test = ->
  try
    stats = fs.statSync 'test.txt'
    code = fs.readFileSync 'test.txt'
  catch err
    console.log "Error:", err.message

  # These should work now with promoted variables
  console.log "Stats:", stats
  console.log "Code:", code

test()
