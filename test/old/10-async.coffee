# Async/Await and Generators
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify async features work correctly

# Basic async functions
test "typeof (-> await 1)", "function"
test "(-> await Promise.resolve(42))() instanceof Promise", true

# Async function with await
test "await (-> await Promise.resolve(5))()", 5
test "await (-> x = await Promise.resolve(10); x * 2)()", 20

# Multiple awaits
test """
  asyncFunc = ->
    a = await Promise.resolve(1)
    b = await Promise.resolve(2)
    a + b
  await asyncFunc()
""", 3

# Async with try/catch
test """
  asyncFunc = ->
    try
      await Promise.resolve('success')
    catch e
      'error'
  await asyncFunc()
""", "success"

# Async with rejection handling
test """
  asyncFunc = ->
    try
      await Promise.reject(new Error('test'))
      'should not reach'
    catch e
      'caught'
  await asyncFunc()
""", "caught"

# Async arrow functions
test "f = => await Promise.resolve(7); await f()", 7
test "add = (a, b) => await Promise.resolve(a + b); await add(3, 4)", 7

# Async in objects
test """
  obj = {
    value: -> await Promise.resolve(42)
  }
  await obj.value()
""", 42

# Async in classes
test """
  class AsyncClass
    getValue: -> await Promise.resolve(99)
  instance = new AsyncClass()
  await instance.getValue()
""", 99

# Promise.all with async
test """
  await Promise.all([
    Promise.resolve(1)
    Promise.resolve(2)
    Promise.resolve(3)
  ]).then (values) -> values.join(',')
""", "1,2,3"

# Async with timeout
test """
  delay = (ms) -> new Promise (resolve) -> setTimeout(resolve, ms)
  asyncFunc = ->
    await delay(1)
    'done'
  await asyncFunc()
""", "done"

# Generator functions
test "gen = -> yield 1; g = gen(); g.next().value", 1
test """
  gen = ->
    yield 1
    yield 2
    yield 3
  g = gen()
  [g.next().value, g.next().value, g.next().value]
""", [1, 2, 3]

# Generator with return
test """
  gen = ->
    yield 1
    return 2
  g = gen()
  g.next()
  g.next().value
""", 2

# Generator with yield*
test """
  gen1 = ->
    yield 1
    yield 2
  gen2 = ->
    yield* gen1()
    yield 3
  g = gen2()
  [g.next().value, g.next().value, g.next().value]
""", [1, 2, 3]

# Async generators
test """
  asyncGen = ->
    yield await Promise.resolve(1)
    yield await Promise.resolve(2)
  g = asyncGen()
  a = await g.next()
  b = await g.next()
  [a.value, b.value]
""", [1, 2]

# for await...of loops
test """
  asyncIterable = {
    [Symbol.asyncIterator]: ->
      i = 0
      {
        next: ->
          i++
          if i <= 3
            Promise.resolve({value: i, done: false})
          else
            Promise.resolve({done: true})
      }
  }
  result = []
  for await val from asyncIterable
    result.push(val)
  result.join(',')
""", "1,2,3"

# Async comprehensions
test """
  promises = (Promise.resolve(i) for i in [1, 2, 3])
  await Promise.all(promises).then (values) -> values.join(',')
""", "1,2,3"

# Async with destructuring
test """
  asyncFunc = ->
    {x, y} = await Promise.resolve({x: 10, y: 20})
    x + y
  await asyncFunc()
""", 30

# Chained promises
test """
  await Promise.resolve(5)
    .then (x) -> x * 2
    .then (x) -> x + 3
""", 13

# Async IIFE
test "await do -> await Promise.resolve(123)", 123

# Parallel async operations
test """
  [a, b] = await Promise.all([
    Promise.resolve(10)
    Promise.resolve(20)
  ])
  a + b
""", 30

# Sequential async operations
test """
  result = 0
  result += await Promise.resolve(1)
  result += await Promise.resolve(2)
  result += await Promise.resolve(3)
  result
""", 6

# Async with conditional
test """
  getValue = (condition) ->
    if condition
      await Promise.resolve('true')
    else
      await Promise.resolve('false')
  await getValue(true)
""", "true"

# Nested async functions
test """
  outer = ->
    inner = ->
      await Promise.resolve(5)
    (await inner()) * 2
  await outer()
""", 10

# Promise.race
test """
  delay = (ms, value) ->
    new Promise (resolve) ->
      setTimeout (-> resolve(value)), ms
  await Promise.race([
    delay(100, 'slow')
    Promise.resolve('fast')
  ])
""", "fast"

# Async method in class inheritance
test """
  class Base
    getValue: -> await Promise.resolve(1)

  class Derived extends Base
    getValue: -> (await super()) + 1

  d = new Derived()
  await d.getValue()
""", 2

# Tests moved from 01-functions.coffee
test """
  delay = (ms) -> new Promise (resolve) -> setTimeout(resolve, ms)
  asyncFunc = ->
    await delay(1)
    'done'
  await asyncFunc()
""", 'done'

# Tests moved from 12-exceptions.coffee
test """
  f = ->
    try
      await Promise.reject(new Error('async error'))
    catch e
      'caught async'
  await f()
""", "caught async"

test """
  f = ->
    try
      await Promise.resolve('async success')
    catch e
      'should not catch'
  await f()
""", "async success"

# Tests moved from 17-iteration-patterns.coffee

# For-from loops (async iteration)
test "(x for x from [1, 2, 3]).join(',')", "1,2,3"
test "(x * 2 for x from [1, 2, 3]).join(',')", "2,4,6"
test "(x for x from [1, 2, 3] when x > 1).join(',')", "2,3"

# For-from with async iterables
test """
  asyncIterable = {
    [Symbol.asyncIterator]: ->
      values = [1, 2, 3]
      i = 0
      {
        next: ->
          if i < values.length
            Promise.resolve({value: values[i++], done: false})
          else
            Promise.resolve({done: true})
      }
  }
  results = []
  for await x from asyncIterable
    results.push(x)
  results.join(',')
""", "1,2,3"

# For-await-of pattern
test """
  asyncGen = ->
    yield await Promise.resolve(1)
    yield await Promise.resolve(2)
    yield await Promise.resolve(3)

  results = []
  for await value from asyncGen()
    results.push(value)
  results.join(',')
""", "1,2,3"

# Compilation output tests
code "await x", "await x;"
code "await func()", "await func();"

# Invalid syntax tests
fail "await without async"  # await must be in async function
