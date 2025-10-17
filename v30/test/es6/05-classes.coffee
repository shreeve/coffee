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

# Note: CoffeeScript doesn't support ES6 getter/setter syntax directly
# Using Object.defineProperty forces an IIFE wrapper (not ideal ES6)
# For true ES6 getters/setters, you'd need: get fullName() { ... }
# which CoffeeScript doesn't support

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
    * count() {
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

test "class instantiation", '''
  Person = class
    constructor: (@name) ->
  person = new Person("Alice")
  person.name
''', "Alice"

test "class methods work", '''
  Calculator = class
    add: (a, b) -> a + b
  calc = new Calculator()
  calc.add(2, 3)
''', 5

test "inheritance works", '''
  Animal = class
    constructor: (@name) ->
  Dog = class extends Animal
    speak: -> "Woof!"
  dog = new Dog("Rex")
  dog.speak()
''', "Woof!"

test "static methods work", '''
  MathUtils = class
    @square: (x) -> x * x
  MathUtils.square(4)
''', 16

test "super calls work", '''
  Parent = class
    constructor: (@value) ->
  Child = class extends Parent
    constructor: (v) -> super(v * 2)
  child = new Child(5)
  child.value
''', 10