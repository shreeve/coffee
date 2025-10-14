# CS300 ES6 Output Roadmap

## 🎯 Goal
Transform CS300 to generate modern ES6+ JavaScript output instead of ES5.

## 📊 Current State vs Target State

### Current ES5 Output
```javascript
// IIFE wrapper
(function() {
  // Variable hoisting with var
  var x, y, MyClass;

  // ES5 function syntax
  x = function(arg) {
    return arg * 2;
  };

  // ES5 class pattern
  MyClass = (function() {
    function MyClass(name) {
      this.name = name;
    }
    return MyClass;
  })();

}).call(this);
```

### Target ES6+ Output
```javascript
// No IIFE needed for modules
// Imports at top
import { something } from './module.js'

// Modern declarations
const x = (arg) => arg * 2
let y = 10

// ES6 classes
class MyClass {
  constructor(name) {
    this.name = name
  }
}

// Exports at bottom
export { MyClass, x }
```

## 🔧 Major Transformation Areas

### 1. **Variable Declarations**
- [ ] Replace `var` with `const`/`let` based on mutability analysis
- [ ] Remove variable hoisting (declare at first use)
- [ ] Implement scope tracking for block-scoped variables

### 2. **Module System**
- [ ] Remove IIFE wrappers `(function() { ... }).call(this)`
- [ ] Generate ES6 `import` statements at top
- [ ] Generate ES6 `export` statements at bottom
- [ ] Handle default exports vs named exports
- [ ] Transform `require()` → `import`
- [ ] Transform `module.exports` → `export`

### 3. **Function Definitions**
- [ ] Use arrow functions where appropriate (no `this` binding needed)
- [ ] Use concise method syntax in objects/classes
- [ ] Use default parameters instead of `arg || defaultValue`
- [ ] Use rest parameters `...args` instead of `arguments`

### 4. **Classes**
- [ ] Generate native ES6 classes
- [ ] Use `extends` for inheritance
- [ ] Use `super()` for parent constructor calls
- [ ] Static methods with `static` keyword
- [ ] Class fields (public/private)

### 5. **Syntax Modernization**
- [ ] Template literals for string interpolation
- [ ] Object shorthand `{ x }` instead of `{ x: x }`
- [ ] Computed property names `{ [key]: value }`
- [ ] Destructuring in parameters and assignments
- [ ] Spread operator for arrays/objects
- [ ] `for...of` loops where appropriate

### 6. **Async/Await**
- [ ] Native async/await (already supported?)
- [ ] Promise-based patterns
- [ ] Remove callback-style transforms

### 7. **Style Decisions**
- [ ] Remove semicolons (except where needed)
- [ ] Use single quotes or template literals
- [ ] Consistent spacing and formatting
- [ ] Preserve source indentation where possible

## 🏗️ Implementation Plan

### Phase 1: Foundation (Core Infrastructure)
1. **Create Compiler Option**
   - Add `target: 'es6'` option to compile()
   - Route to different code generation based on target

2. **Scope Analysis Enhancement**
   - Track variable mutability (const vs let)
   - Track block scopes for let/const
   - Identify pure functions (can be arrow functions)

3. **Module Detection**
   - Detect import/export usage in source
   - Track module dependencies

### Phase 2: Core Transformations
4. **Variable System**
   - Implement const/let generation
   - Remove var hoisting logic
   - Update Scope class to handle block scoping

5. **Remove IIFEs**
   - Detect module context
   - Skip wrapper generation for modules
   - Preserve for scripts (non-module code)

6. **Function Modernization**
   - Identify arrow function candidates
   - Convert simple functions to arrows
   - Preserve `function` for methods needing `this`

### Phase 3: ES6 Features
7. **Classes**
   - Generate ES6 class syntax
   - Handle constructors and methods
   - Implement extends/super

8. **Template Literals**
   - Convert string interpolation
   - Multi-line strings

9. **Destructuring**
   - Parameter destructuring
   - Assignment destructuring

### Phase 4: Advanced Features
10. **Import/Export**
    - Generate import statements
    - Handle various export patterns
    - Source map support

11. **Modern Syntax**
    - Object shorthand
    - Spread operators
    - Optional chaining (ES2020)
    - Nullish coalescing (ES2020)

### Phase 5: Optimization & Polish
12. **Code Quality**
    - Remove unnecessary semicolons
    - Optimize output formatting
    - Minimize generated code size

13. **Testing & Compatibility**
    - Comprehensive test suite
    - Browser compatibility checks
    - Node.js compatibility

## 📁 Key Files to Modify

### Primary Files
1. **`nodes.js`** - Core AST nodes and compilation methods
   - `compileNode()` methods for each node type
   - `compileToFragments()` for code generation

2. **`scope.js`** - Variable scope tracking
   - Add mutability tracking
   - Block scope support

3. **`coffeescript.js`** - Compiler entry point
   - Add target option handling
   - Route to appropriate backend

### New Files to Create
4. **`es6-generator.js`** (optional)
   - Dedicated ES6 code generation
   - Transformation rules
   - ES6-specific optimizations

## 🧪 Testing Strategy

### Test Categories
1. **Syntax Tests** - Each ES6 feature
2. **Compatibility Tests** - Runs in modern browsers/Node
3. **Regression Tests** - Existing tests still pass
4. **Performance Tests** - Output runs efficiently
5. **Source Map Tests** - Debugging works correctly

### Test Examples
```coffeescript
# Input CoffeeScript
class Animal
  constructor: (@name) ->
  speak: => console.log "#{@name} makes a sound"

dog = new Animal 'Rex'
dog.speak()
```

```javascript
// Expected ES6 Output
class Animal {
  constructor(name) {
    this.name = name
  }

  speak = () => console.log(`${this.name} makes a sound`)
}

const dog = new Animal('Rex')
dog.speak()
```

## 🚀 Implementation Order

### Quick Wins (Start Here)
1. Remove IIFE wrapper for `bare: true` option
2. Simple arrow functions for anonymous functions
3. Template literals for string interpolation
4. const/let for simple cases

### Medium Complexity
5. ES6 classes
6. Object shorthand
7. Destructuring
8. Rest/spread operators

### Complex Features
9. Full module system (import/export)
10. Mutability analysis for const/let
11. Block scoping
12. Async/await improvements

## 🎨 Configuration Options

```coffeescript
CoffeeScript.compile code,
  target: 'es6'        # 'es5' (default) | 'es6' | 'esnext'
  modules: 'es6'       # 'commonjs' | 'es6' | 'none'
  semicolons: false    # Include semicolons
  arrows: 'auto'       # 'auto' | 'always' | 'never'
  constlet: true       # Use const/let instead of var
```

## 📈 Success Metrics

- [ ] All existing tests pass with ES6 output
- [ ] Output runs in Node 14+ without transpilation
- [ ] Output runs in modern browsers (Chrome 90+, Firefox 88+, Safari 14+)
- [ ] Generated code is readable and debuggable
- [ ] File size reduction (no IIFE overhead)
- [ ] Performance improvement (native features)

## 🔍 Research Areas

1. **Other Compilers** - Study Babel, TypeScript ES6 output
2. **Best Practices** - Modern JavaScript patterns
3. **Compatibility** - Browser/Node version requirements
4. **Tree Shaking** - Enable bundle optimization
5. **Source Maps** - Maintain debugging experience

## 📝 Notes

- Start with opt-in ES6 via compiler flag
- Maintain backwards compatibility with ES5 output
- Consider progressive enhancement approach
- Document breaking changes clearly
- Provide migration guide for users
