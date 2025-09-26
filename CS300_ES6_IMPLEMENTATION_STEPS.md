# CS300 ES6 Output - Implementation Checklist

## 🏃 Quick Start Path

### Step 1: Add Compiler Option (Day 1)
```coffeescript
# In coffeescript.js
compile = (code, options = {}) ->
  options.target ?= 'es5'  # Add 'es6' option
```
- [ ] Add `target` option to compile function
- [ ] Pass option through to nodes
- [ ] Create basic switch for output mode

### Step 2: Remove IIFE Wrapper (Day 1)
```javascript
// Current: (function() { ... }).call(this)
// Target:  [no wrapper for modules]
```
- [ ] In `Root.compileNode()`, check for ES6 target
- [ ] Skip IIFE generation when `target: 'es6'`
- [ ] Test with simple expressions

### Step 3: Basic const/let (Day 2)
```javascript
// Current: var x, y;  x = 10;  y = 20;
// Target:  const x = 10;  let y = 20;
```
- [ ] Modify `Assign.compileNode()` for inline declaration
- [ ] Track first assignment in Scope
- [ ] Default to `const`, use `let` when reassigned

### Step 4: Arrow Functions (Day 2-3)
```javascript
// Current: x = function(a) { return a * 2; };
// Target:  const x = (a) => a * 2;
```
- [ ] Detect simple functions without `this`
- [ ] Convert to arrow syntax in `Code.compileNode()`
- [ ] Handle implicit returns

### Step 5: Template Literals (Day 3)
```javascript
// Current: "Hello " + name + "!"
// Target:  `Hello ${name}!`
```
- [ ] Modify `StringWithInterpolations.compileNode()`
- [ ] Use backticks and `${}` syntax
- [ ] Handle multiline strings

### Step 6: ES6 Classes (Day 4-5)
```javascript
// Current: ES5 prototype pattern
// Target:  class Animal { constructor() {} }
```
- [ ] Completely rewrite `Class.compileNode()`
- [ ] Generate ES6 class syntax
- [ ] Handle methods and constructor

## 📋 Detailed Implementation Tasks

### Module System Tasks
- [ ] **Import Generation**
  - Detect CoffeeScript import statements
  - Hoist to top of file
  - Generate ES6 import syntax
  - Handle default vs named imports
  
- [ ] **Export Generation**
  - Track exported symbols
  - Generate export statements at bottom
  - Handle default exports
  - Named exports with aliases

- [ ] **Require Transform**
  - Convert `require()` calls to imports
  - Handle dynamic requires
  - Warn on incompatible patterns

### Variable Declaration Tasks
- [ ] **Mutability Analysis**
  - Track all assignments to each variable
  - Mark single-assignment as `const`
  - Mark multi-assignment as `let`
  - Never use `var`

- [ ] **Scope Enhancement**
  - Add block scope tracking
  - Handle let/const in for loops
  - Temporal dead zone awareness
  - Shadowing detection

- [ ] **Declaration Point**
  - Declare at first use (not hoisted)
  - Combine declaration with initialization
  - Handle destructuring declarations

### Function Transformation Tasks
- [ ] **Arrow Function Detection**
  - Identify functions not using `this`
  - Identify functions not using `arguments`
  - Convert simple expressions to arrows
  - Preserve function declarations when needed

- [ ] **Method Syntax**
  - Use concise method syntax in objects
  - Use class method syntax
  - Handle getters/setters
  - Static methods

- [ ] **Parameter Features**
  - Default parameters
  - Rest parameters `...args`
  - Destructuring in parameters
  - No arguments object usage

### Class Generation Tasks
- [ ] **Class Structure**
  - ES6 class declaration
  - Constructor method
  - Instance methods
  - Static methods
  - Class fields (ES2022)

- [ ] **Inheritance**
  - `extends` keyword
  - `super()` calls
  - Method overriding
  - Static inheritance

### Syntax Modernization Tasks
- [ ] **Object Features**
  - Shorthand properties `{ x }` 
  - Computed properties `{ [key]: val }`
  - Method shorthand
  - Spread in objects

- [ ] **Array Features**  
  - Spread operator `[...arr]`
  - Destructuring assignments
  - for...of loops
  - Array methods (map, filter, etc.)

- [ ] **String Features**
  - Template literals
  - Multi-line strings
  - Tagged templates
  - Raw strings

### Code Style Tasks
- [ ] **Semicolon Removal**
  - Remove unnecessary semicolons
  - Keep where required (before `[` or `(`)
  - Configurable option

- [ ] **Formatting**
  - Consistent indentation
  - Spacing around operators
  - Line length management
  - Comment preservation

## 🔧 File-by-File Changes

### `nodes.js` Modifications

#### Root Class
```javascript
// compileNode method
if (o.target === 'es6' && !o.globals) {
  // Don't wrap in IIFE for ES6 modules
  return fragments
}
```

#### Assign Class
```javascript
// compileNode method  
if (o.target === 'es6') {
  // Use const/let based on mutability
  const declareWord = this.isConst() ? 'const' : 'let'
  // Inline declaration with initialization
}
```

#### Code Class
```javascript
// compileNode method
if (o.target === 'es6' && this.isArrowCandidate()) {
  // Generate arrow function syntax
  // Handle implicit return
}
```

#### Class Class
```javascript
// compileNode method
if (o.target === 'es6') {
  // Generate ES6 class syntax
  // Use constructor() method
  // Use extends for inheritance
}
```

### `scope.js` Modifications

#### New Methods Needed
```coffeescript
# Track variable mutability
trackAssignment: (name) ->
  @assignments[name] = (@assignments[name] || 0) + 1

# Determine const vs let
getDeclaration: (name) ->
  if @assignments[name] <= 1 then 'const' else 'let'

# Block scope support
enterBlock: -> 
  @blockScopes.push({})
  
exitBlock: ->
  @blockScopes.pop()
```

### `coffeescript.js` Modifications

#### Compile Function
```javascript
compile(code, options = {}) {
  // Default options
  options.target ??= 'es5'  // 'es5' | 'es6' | 'esnext'
  options.modules ??= options.target === 'es6' ? 'es6' : 'commonjs'
  
  // Pass through compilation pipeline
  const ast = this.nodes(code)
  return ast.compile(options)
}
```

## ⚡ Priority Order

### Week 1: Core Infrastructure
1. **Monday**: Add compiler options, basic ES6 flag routing
2. **Tuesday**: Remove IIFE wrapper for ES6 target
3. **Wednesday**: Basic const/let replacement for var
4. **Thursday**: Simple arrow functions
5. **Friday**: Template literals for string interpolation

### Week 2: Essential Features  
6. **Monday**: ES6 class generation
7. **Tuesday**: Object shorthand and computed properties
8. **Wednesday**: Destructuring assignments
9. **Thursday**: Spread operators
10. **Friday**: for...of loops and iterators

### Week 3: Module System
11. **Monday**: Import statement generation
12. **Tuesday**: Export statement generation  
13. **Wednesday**: require() transformation
14. **Thursday**: Module vs script detection
15. **Friday**: Dynamic import support

### Week 4: Polish & Testing
16. **Monday**: Mutability analysis refinement
17. **Tuesday**: Block scoping edge cases
18. **Wednesday**: Source map updates
19. **Thursday**: Performance optimization
20. **Friday**: Documentation and examples

## 🧪 Test-Driven Development

### For Each Feature:
1. Write test case with expected ES6 output
2. Implement minimal code to pass test
3. Refactor and optimize
4. Add edge case tests
5. Update documentation

### Example Test:
```coffeescript
# test/es6_output_test.coffee
test "generates const for immutable variables", ->
  input = "x = 42"
  output = CoffeeScript.compile(input, target: 'es6', bare: true)
  eq output.trim(), "const x = 42"

test "generates let for mutable variables", ->
  input = """
    x = 42
    x = 100
  """
  output = CoffeeScript.compile(input, target: 'es6', bare: true)
  ok output.includes("let x = 42")
  ok output.includes("x = 100")
```

## 🎯 Success Criteria

Each feature is complete when:
- [ ] Tests pass for the feature
- [ ] Output runs in Node 14+
- [ ] Output runs in modern browsers
- [ ] No regression in existing tests
- [ ] Documentation updated
- [ ] Code reviewed and optimized
