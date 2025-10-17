###
ES6 Modern Loops Test Suite
============================

CoffeeScript 3.0 should generate modern ES6 loop constructs:
- Comprehensions → Array methods (.map, .filter, .reduce)
- Simple loops → for...of (when safe)
- Traditional loops → for complex cases (by, when, break/continue)
- Post-loop variable access → function-scoped let
###

# Test helper to validate generated JavaScript
code = (coffee, js) ->
  try
    compiled = CoffeeScript.compile(coffee, bare: true).trim()
    expected = js.trim()
    if compiled is expected
      console.log "✓", coffee.replace(/\n/g, ' ').substring(0, 50)
    else
      console.log "✗", coffee.replace(/\n/g, ' ').substring(0, 50)
      console.log "    Expected JS:", expected.replace(/\n/g, '\n    ')
      console.log "    Got JS:     ", compiled.replace(/\n/g, '\n    ')
  catch err
    console.log "✗", coffee.replace(/\n/g, ' ').substring(0, 50)
    console.log "    Compilation Error:", err.message

console.log "CoffeeScript 3.0 ES6 Modern Loops Test Suite"
console.log "=" .repeat 50

# ==============================================================================
# COMPREHENSIONS → ARRAY METHODS (Most idiomatic ES6)
# ==============================================================================

console.log "\n== Comprehensions → Array Methods =="

# Simple map comprehension
code '''
  doubles = (x * 2 for x in numbers)
''', '''
  let doubles;

  doubles = numbers.map((x) => x * 2);
'''

# Simple filter comprehension
code '''
  evens = (x for x in numbers when x % 2 is 0)
''', '''
  let evens;

  evens = numbers.filter((x) => x % 2 === 0);
'''

# Filter then map (chained)
code '''
  result = (x * 2 for x in numbers when x > 5)
''', '''
  let result;

  result = numbers.filter((x) => x > 5).map((x) => x * 2);
'''

# Map with complex expression
code '''
  names = (user.name.toUpperCase() for user in users)
''', '''
  let names;

  names = users.map((user) => user.name.toUpperCase());
'''

# Filter with complex condition
code '''
  active = (u for u in users when u.active and u.verified)
''', '''
  let active;

  active = users.filter((u) => u.active && u.verified);
'''

# Nested comprehension (edge case - might stay traditional)
code '''
  matrix = ((i * j for j in [1..3]) for i in [1..3])
''', '''
  let i, matrix;

  matrix = (() => {
    let j, k, results;
    results = [];
    for (i = j = 1; j <= 3; i = ++j) {
      results.push((() => {
        let l, m, results1;
        results1 = [];
        for (k = l = 1; l <= 3; k = ++l) {
          results1.push(i * k);
        }
        return results1;
      })());
    }
    return results;
  })();
'''

# ==============================================================================
# SIMPLE LOOPS → for...of
# ==============================================================================

console.log "\n== Simple Loops → for...of =="

# Basic array iteration (no post-loop access)
code '''
  for item in items
    console.log item
''', '''
  for (let item of items) {
    console.log(item);
  }
'''

# Loop with multiple statements
code '''
  for user in users
    console.log user.name
    console.log user.email
''', '''
  for (let user of users) {
    console.log(user.name);
    console.log(user.email);
  }
'''

# Loop with index (could use .forEach or .entries)
code '''
  for item, i in items
    console.log i, item
''', '''
  items.forEach((item, i) => console.log(i, item));
'''

# Object iteration
code '''
  for key, value of obj
    console.log key, value
''', '''
  for (let [key, value] of Object.entries(obj)) {
    console.log(key, value);
  }
'''

# ==============================================================================
# POST-LOOP VARIABLE ACCESS (Critical edge case)
# ==============================================================================

console.log "\n== Post-Loop Variable Access =="

# Variable used after loop - must be function-scoped
code '''
  for item in list
    lastItem = item
  console.log lastItem
''', '''
  let item, lastItem;

  for (item of list) {
    lastItem = item;
  }
  console.log(lastItem);
'''

# Index variable used after loop
code '''
  for item, i in items
    continue
  console.log i
''', '''
  let i, item;

  for (i = 0; i < items.length; i++) {
    item = items[i];
    continue;
  }
  console.log(i);
'''

# ==============================================================================
# BREAK/CONTINUE (Must use loops, not methods)
# ==============================================================================

console.log "\n== Break/Continue Statements =="

# Loop with break
code '''
  for item in items
    break if item.done
    console.log item
''', '''
  for (let item of items) {
    if (item.done) {
      break;
    }
    console.log(item);
  }
'''

# Loop with continue
code '''
  for item in items
    continue if item.skip
    process(item)
''', '''
  for (let item of items) {
    if (item.skip) {
      continue;
    }
    process(item);
  }
'''

# Early exit with break (can't use .forEach)
code '''
  found = null
  for item in items
    if item.id is targetId
      found = item
      break
''', '''
  let found, item;

  found = null;
  for (item of items) {
    if (item.id === targetId) {
      found = item;
      break;
    }
  }
'''

# ==============================================================================
# TRADITIONAL LOOPS (Complex cases)
# ==============================================================================

console.log "\n== Traditional Loops (Complex Cases) =="

# Loop with by step
code '''
  for i in [0..10] by 2
    console.log i
''', '''
  let i, j;

  for (i = j = 0; j <= 10; i = j += 2) {
    console.log(i);
  }
'''

# Loop with own properties check
code '''
  for own key, value of obj
    console.log key, value
''', '''
  let key, value;

  for (key in obj) {
    if (!hasProp.call(obj, key)) continue;
    value = obj[key];
    console.log(key, value);
  }
'''

# Reverse range
code '''
  for i in [10..1]
    console.log i
''', '''
  let i, j;

  for (i = j = 10; j >= 1; i = --j) {
    console.log(i);
  }
'''

# ==============================================================================
# ARRAY METHOD EQUIVALENTS
# ==============================================================================

console.log "\n== Array Method Equivalents =="

# forEach for side effects
code '''
  for item in items
    sideEffect(item)
''', '''
  for (let item of items) {
    sideEffect(item);
  }
'''

# Could be .some() for early exit pattern
code '''
  hasLarge = false
  for n in numbers
    if n > 100
      hasLarge = true
      break
''', '''
  let hasLarge, n;

  hasLarge = false;
  for (n of numbers) {
    if (n > 100) {
      hasLarge = true;
      break;
    }
  }
'''

# Could be .find() for search pattern
code '''
  found = null
  for user in users
    if user.id is targetId
      found = user
      break
''', '''
  let found, user;

  found = null;
  for (user of users) {
    if (user.id === targetId) {
      found = user;
      break;
    }
  }
'''

# ==============================================================================
# OBJECT ITERATION PATTERNS
# ==============================================================================

console.log "\n== Object Iteration =="

# Simple for...in
code '''
  for key of obj
    console.log key
''', '''
  for (let key in obj) {
    console.log(key);
  }
'''

# for...in with value
code '''
  for key, value of obj
    console.log key, value
''', '''
  for (let [key, value] of Object.entries(obj)) {
    console.log(key, value);
  }
'''

# for own key
code '''
  for own key of obj
    console.log key
''', '''
  let key;

  for (key in obj) {
    if (!hasProp.call(obj, key)) continue;
    console.log(key);
  }
'''

# ==============================================================================
# RANGE LOOPS
# ==============================================================================

console.log "\n== Range Loops =="

# Simple ascending range
code '''
  for i in [1..5]
    console.log i
''', '''
  let i, j;

  for (i = j = 1; j <= 5; i = ++j) {
    console.log(i);
  }
'''

# Exclusive range
code '''
  for i in [0...5]
    console.log i
''', '''
  let i, j;

  for (i = j = 0; j < 5; i = ++j) {
    console.log(i);
  }
'''

# ==============================================================================
# WHILE/UNTIL LOOPS
# ==============================================================================

console.log "\n== While/Until Loops =="

# While loop
code '''
  while condition
    doSomething()
''', '''
  while (condition) {
    doSomething();
  }
'''

# Until loop (becomes while not)
code '''
  until finished
    process()
''', '''
  while (!finished) {
    process();
  }
'''

# ==============================================================================
# ASYNC ITERATION
# ==============================================================================

console.log "\n== Async Iteration =="

# Async for loop
code '''
  for url in urls
    await fetch(url)
''', '''
  for (let url of urls) {
    await fetch(url);
  }
'''

# Async comprehension (might need Promise.all optimization)
code '''
  results = (await fetch(url) for url in urls)
''', '''
  let results;

  results = (() => {
    let i, len, results1;
    results1 = [];
    for (i = 0, len = urls.length; i < len; i++) {
      url = urls[i];
      results1.push((await fetch(url)));
    }
    return results1;
  })();
'''

# ==============================================================================
# EDGE CASES & SPECIAL PATTERNS
# ==============================================================================

console.log "\n== Edge Cases =="

# Empty loop (rare but valid)
code '''
  for item in []
    console.log item
''', '''
  for (let item of []) {
    console.log(item);
  }
'''

# Loop with destructured item
code '''
  for {name, age} in people
    console.log name, age
''', '''
  for (let {name, age} of people) {
    console.log(name, age);
  }
'''

# Loop with splat/rest
code '''
  for [first, ...rest] in pairs
    console.log first, rest
''', '''
  for (let [first, ...rest] of pairs) {
    console.log(first, rest);
  }
'''

# Standalone comprehension (immediate evaluation)
code '''
  (console.log x for x in [1, 2, 3])
''', '''
  [1, 2, 3].forEach((x) => console.log(x));
'''

console.log "\n== Test Complete =="
passed = 0
failed = 0
for line in console.log.calls ? []
  passed++ if line[0]?.includes? '✓'
  failed++ if line[0]?.includes? '✗'

console.log "\n[1mSummary:[0m"
console.log "[32mPassed: #{passed}[0m"
console.log "[31mFailed: #{failed}[0m"
console.log "Success rate: #{Math.round(passed / (passed + failed) * 100)}%"
