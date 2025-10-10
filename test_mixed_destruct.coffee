# Mixed destructuring - some properties, some new variables
obj = {}
[obj.a, obj.b, newVar] = [1, 2, 3]
console.log obj, newVar
