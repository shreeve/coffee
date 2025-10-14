# CS300 ES6 Transform Examples

## Side-by-Side Comparison: Current ES5 vs Target ES6

### Variables

#### Simple Assignment
```coffeescript
# CoffeeScript
x = 42
y = "hello"
```

```javascript
// Current ES5
(function() {
  var x, y;
  x = 42;
  y = "hello";
}).call(this);

// Target ES6
const x = 42
const y = "hello"
```

#### Mutable Variable
```coffeescript
# CoffeeScript
counter = 0
counter = counter + 1
```

```javascript
// Current ES5
var counter;
counter = 0;
counter = counter + 1;

// Target ES6
let counter = 0
counter = counter + 1
```

### Functions

#### Simple Function
```coffeescript
# CoffeeScript
double = (x) -> x * 2
```

```javascript
// Current ES5
var double;
double = function(x) {
  return x * 2;
};

// Target ES6
const double = (x) => x * 2
```

#### Function with Multiple Statements
```coffeescript
# CoffeeScript
process = (data) ->
  console.log "Processing..."
  data * 2
```

```javascript
// Current ES5
var process;
process = function(data) {
  console.log("Processing...");
  return data * 2;
};

// Target ES6
const process = (data) => {
  console.log("Processing...")
  return data * 2
}
```

#### Method Definition
```coffeescript
# CoffeeScript
obj =
  name: "Test"
  greet: -> console.log @name
```

```javascript
// Current ES5
var obj;
obj = {
  name: "Test",
  greet: function() {
    return console.log(this.name);
  }
};

// Target ES6
const obj = {
  name: "Test",
  greet() {
    console.log(this.name)
  }
}
```

### Classes

#### Basic Class
```coffeescript
# CoffeeScript
class Animal
  constructor: (@name) ->

  speak: ->
    console.log "#{@name} says hello"
```

```javascript
// Current ES5
var Animal;
Animal = (function() {
  function Animal(name) {
    this.name = name;
  }

  Animal.prototype.speak = function() {
    return console.log(this.name + " says hello");
  };

  return Animal;
})();

// Target ES6
class Animal {
  constructor(name) {
    this.name = name
  }

  speak() {
    console.log(`${this.name} says hello`)
  }
}
```

#### Class with Static Method
```coffeescript
# CoffeeScript
class User
  @findById: (id) ->
    console.log "Finding user #{id}"
```

```javascript
// Current ES5
var User;
User = (function() {
  function User() {}

  User.findById = function(id) {
    return console.log("Finding user " + id);
  };

  return User;
})();

// Target ES6
class User {
  static findById(id) {
    console.log(`Finding user ${id}`)
  }
}
```

#### Class Inheritance
```coffeescript
# CoffeeScript
class Dog extends Animal
  constructor: (name, @breed) ->
    super name

  speak: ->
    super()
    console.log "Woof!"
```

```javascript
// Current ES5
var Dog,
  extend = function(child, parent) { /*...*/ };

Dog = (function(superClass) {
  extend(Dog, superClass);

  function Dog(name, breed) {
    this.breed = breed;
    Dog.__super__.constructor.call(this, name);
  }

  Dog.prototype.speak = function() {
    Dog.__super__.speak.call(this);
    return console.log("Woof!");
  };

  return Dog;
})(Animal);

// Target ES6
class Dog extends Animal {
  constructor(name, breed) {
    super(name)
    this.breed = breed
  }

  speak() {
    super.speak()
    console.log("Woof!")
  }
}
```

### String Interpolation

```coffeescript
# CoffeeScript
name = "World"
message = "Hello #{name}!"
multiline = """
  Dear #{name},
  How are you?
"""
```

```javascript
// Current ES5
var message, multiline, name;
name = "World";
message = "Hello " + name + "!";
multiline = "Dear " + name + ",\nHow are you?";

// Target ES6
const name = "World"
const message = `Hello ${name}!`
const multiline = `Dear ${name},
How are you?`
```

### Destructuring

#### Array Destructuring
```coffeescript
# CoffeeScript
[first, second, rest...] = array
```

```javascript
// Current ES5
var first, rest, second;
first = array[0], second = array[1], rest = 3 <= array.length ? slice.call(array, 2) : [];

// Target ES6
const [first, second, ...rest] = array
```

#### Object Destructuring
```coffeescript
# CoffeeScript
{name, age, city = "Unknown"} = person
```

```javascript
// Current ES5
var age, city, name;
name = person.name, age = person.age, city = person.city != null ? person.city : "Unknown";

// Target ES6
const {name, age, city = "Unknown"} = person
```

#### Parameter Destructuring
```coffeescript
# CoffeeScript
processUser = ({name, email}) ->
  console.log name, email
```

```javascript
// Current ES5
var processUser;
processUser = function(arg) {
  var email, name;
  name = arg.name, email = arg.email;
  return console.log(name, email);
};

// Target ES6
const processUser = ({name, email}) => {
  console.log(name, email)
}
```

### Loops

#### For...of Loop
```coffeescript
# CoffeeScript
for item in array
  console.log item
```

```javascript
// Current ES5
var i, item, len;
for (i = 0, len = array.length; i < len; i++) {
  item = array[i];
  console.log(item);
}

// Target ES6
for (const item of array) {
  console.log(item)
}
```

#### Object Iteration
```coffeescript
# CoffeeScript
for key, value of object
  console.log key, value
```

```javascript
// Current ES5
var key, value;
for (key in object) {
  value = object[key];
  console.log(key, value);
}

// Target ES6
for (const [key, value] of Object.entries(object)) {
  console.log(key, value)
}
```

### Spread Operator

#### Array Spread
```coffeescript
# CoffeeScript
combined = [first, middle..., last]
```

```javascript
// Current ES5
var combined;
combined = [first].concat(slice.call(middle), [last]);

// Target ES6
const combined = [first, ...middle, last]
```

#### Function Arguments
```coffeescript
# CoffeeScript
log = (first, rest...) ->
  console.log first, rest
```

```javascript
// Current ES5
var log;
log = function() {
  var first, rest;
  first = arguments[0], rest = 2 <= arguments.length ? slice.call(arguments, 1) : [];
  return console.log(first, rest);
};

// Target ES6
const log = (first, ...rest) => {
  console.log(first, rest)
}
```

### Object Shorthand

```coffeescript
# CoffeeScript
name = "Alice"
age = 30
person = {name, age, greet}
```

```javascript
// Current ES5
var age, name, person;
name = "Alice";
age = 30;
person = {
  name: name,
  age: age,
  greet: greet
};

// Target ES6
const name = "Alice"
const age = 30
const person = {name, age, greet}
```

### Default Parameters

```coffeescript
# CoffeeScript
greet = (name = "World") ->
  console.log "Hello #{name}"
```

```javascript
// Current ES5
var greet;
greet = function(name) {
  if (name == null) {
    name = "World";
  }
  return console.log("Hello " + name);
};

// Target ES6
const greet = (name = "World") => {
  console.log(`Hello ${name}`)
}
```

### Async/Await

```coffeescript
# CoffeeScript
fetchData = ->
  await fetch '/api/data'

processData = ->
  data = await fetchData()
  console.log data
```

```javascript
// Current ES5
var fetchData, processData;
fetchData = async function() {
  return await fetch('/api/data');
};

processData = async function() {
  var data;
  data = await fetchData();
  return console.log(data);
};

// Target ES6
const fetchData = async () => {
  return await fetch('/api/data')
}

const processData = async () => {
  const data = await fetchData()
  console.log(data)
}
```

### Module Import/Export

```coffeescript
# CoffeeScript
import React from 'react'
import {render} from 'react-dom'
import * as utils from './utils'

export default MyComponent
export {helper1, helper2}
```

```javascript
// Current ES5 (would error or use require)
// Not directly supported

// Target ES6
import React from 'react'
import {render} from 'react-dom'
import * as utils from './utils'

export default MyComponent
export {helper1, helper2}
```

### Fat Arrow Binding

```coffeescript
# CoffeeScript
class Button
  constructor: ->
    @count = 0

  handleClick: =>
    @count++
    console.log @count
```

```javascript
// Current ES5
var Button;
Button = (function() {
  function Button() {
    this.handleClick = bind(this.handleClick, this);
    this.count = 0;
  }

  Button.prototype.handleClick = function() {
    this.count++;
    return console.log(this.count);
  };

  return Button;
})();

// Target ES6
class Button {
  constructor() {
    this.count = 0
  }

  handleClick = () => {
    this.count++
    console.log(this.count)
  }
}
```

## Summary of Transformations

| Feature | ES5 Pattern | ES6 Pattern | Complexity |
|---------|-------------|-------------|------------|
| Variables | `var x` | `const`/`let` | Low |
| IIFE | `(function(){})()` | None (modules) | Low |
| Functions | `function(){}` | Arrow functions | Medium |
| Classes | Prototype pattern | `class` keyword | High |
| Strings | Concatenation | Template literals | Low |
| Destructuring | Manual extraction | Native syntax | Medium |
| Spread | `slice.call()` | `...` operator | Medium |
| For loops | Index iteration | `for...of` | Low |
| Modules | CommonJS | ES6 imports | High |
| Async | Callbacks/Promises | async/await | Low |

## Implementation Priority

### Phase 1: Quick Wins (1 week)
- Remove IIFE wrapper
- Template literals
- const/let basics
- Simple arrow functions

### Phase 2: Core Features (2 weeks)
- ES6 classes
- Destructuring
- Spread operators
- for...of loops

### Phase 3: Advanced (2 weeks)
- Full const/let analysis
- Module imports/exports
- Object shorthand
- Default parameters

### Phase 4: Polish (1 week)
- Remove semicolons
- Code formatting
- Optimization
- Testing
