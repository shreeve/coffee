# Phase 5: ES6 Classes

console.log "\n== ES6 Classes =="

# Basic class
code '''
  class Person
    constructor: (@name) ->
      @age = 0
''', '''
  let Person;

  Person = class Person {
    constructor(name) {
      this.name = name;
      this.age = 0;
    }

  };
'''

# Class methods
code '''
  class Calculator
    add: (a, b) -> a + b
    multiply: (a, b) -> a * b
''', '''
  let Calculator;

  Calculator = class Calculator {
    add(a, b) {
      return a + b;
    }

    multiply(a, b) {
      return a * b;
    }

  };
'''

# Class inheritance
code '''
  class Animal
    constructor: (@name) ->
    
  class Dog extends Animal
    bark: -> "Woof!"
''', '''
  let Animal, Dog;

  Animal = class Animal {
    constructor(name) {
      this.name = name;
    }

  };

  Dog = class Dog extends Animal {
    bark() {
      return "Woof!";
    }

  };
'''

# Super calls
code '''
  class Child extends Parent
    constructor: (name) ->
      super name
      @type = "child"
''', '''
  let Child;

  Child = class Child extends Parent {
    constructor(name) {
      super(name);
      this.type = "child";
    }

  };
'''

# Static methods
code '''
  class MathUtils
    @square: (x) -> x * x
    @cube: (x) -> x * x * x
''', '''
  let MathUtils;

  MathUtils = class MathUtils {
    static square(x) {
      return x * x;
    }

    static cube(x) {
      return x * x * x;
    }

  };
'''

# Getters and setters
code '''
  class Person
    constructor: (@firstName, @lastName) ->
    
    Object.defineProperty @::, 'fullName',
      get: -> "#{@firstName} #{@lastName}"
      set: (value) ->
        [@firstName, @lastName] = value.split(' ')
''', '''
  let Person;

  Person = class Person {
    constructor(firstName, lastName) {
      this.firstName = firstName;
      this.lastName = lastName;
    }

  };

  Object.defineProperty(Person.prototype, 'fullName', {
    get: function() {
      return `${this.firstName} ${this.lastName}`;
    },
    set: function(value) {
      return [this.firstName, this.lastName] = value.split(' ');
    }
  });
'''

# Async methods
code '''
  class API
    fetchData: (url) ->
      await fetch(url)
''', '''
  let API;

  API = class API {
    async fetchData(url) {
      return (await fetch(url));
    }

  };
'''

# Generator methods
code '''
  class Counter
    count: ->
      yield 1
      yield 2
      yield 3
''', '''
  let Counter;

  Counter = class Counter {
    *count() {
      yield 1;
      yield 2;
      return (yield 3);
    }

  };
'''

# Private fields (using convention)
code '''
  class BankAccount
    constructor: ->
      @_balance = 0
    
    deposit: (amount) ->
      @_balance += amount
''', '''
  let BankAccount;

  BankAccount = class BankAccount {
    constructor() {
      this._balance = 0;
    }

    deposit(amount) {
      return this._balance += amount;
    }

  };
'''

# Class expressions
code '''
  MyClass = class
    method: -> "result"
''', '''
  let MyClass;

  MyClass = class {
    method() {
      return "result";
    }

  };
'''

console.log "\n== Runtime Tests =="

test "class instantiation", ->
  class Person
    constructor: (@name) ->
  
  person = new Person("Alice")
  throw new Error("Expected 'Alice'") unless person.name is "Alice"

test "class methods work", ->
  class Calculator
    add: (a, b) -> a + b
  
  calc = new Calculator()
  throw new Error("Expected 5") unless calc.add(2, 3) is 5

test "inheritance works", ->
  class Animal
    constructor: (@name) ->
    speak: -> "Some sound"
  
  class Dog extends Animal
    speak: -> "Woof!"
  
  dog = new Dog("Rex")
  throw new Error("Expected 'Rex'") unless dog.name is "Rex"
  throw new Error("Expected 'Woof!'") unless dog.speak() is "Woof!"

test "static methods work", ->
  class MathUtils
    @square: (x) -> x * x
  
  throw new Error("Expected 16") unless MathUtils.square(4) is 16

test "super calls work", ->
  class Parent
    constructor: (@value) ->
  
  class Child extends Parent
    constructor: (value) ->
      super(value * 2)
  
  child = new Child(5)
  throw new Error("Expected 10") unless child.value is 10