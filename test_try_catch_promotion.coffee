# Test try/catch variable promotion
test = ->
  try
    data = JSON.parse('{"value": 42}')
    result = data.value * 2
  catch err
    console.log "Error parsing:", err
    data = null  # This should work because 'data' is promoted
    result = 0
  finally
    console.log "Data:", data  # Should be accessible
    console.log "Result:", result  # Should be accessible

test()
