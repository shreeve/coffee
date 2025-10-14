# CoffeeScript 3.0.0 Variable Declarations: const/let with `=!` Sigil

## Overview
Implementation of smart const/let declarations in CoffeeScript 3.0.0 (ES6 output) with an explicit `=!` sigil for forcing const declarations.

## Design Philosophy

### The `=!` Sigil
- **Syntax**: `variable =! value`
- **Semantics**: "Set this value and don't change it!" (the `!` conveys finality/emphasis)
- **Output**: Forces `const` declaration regardless of other heuristics

### Declaration Priority Rules
```coffeescript
# 1. Explicit const sigil (=!) forces const
# 2. Functions are always const
# 3. Classes are always const
# 4. SCREAMING_SNAKE_CASE is const
# 5. Everything else is let (safe default)
```

## Implementation Steps

### 1. Lexer Changes (`v29/src/lexer.coffee`)

Add const sigil detection in the `literalToken` method around line 652:

```coffeescript
# After line 650 (prev = @prev()), add:

    # Check for =! const sigil BEFORE regular assignment handling
    if @chunk.slice(0, 2) is '=!' and prev
      # Make sure previous token is assignable
      if prev and prev[0] isnt 'PROPERTY'
        origin = prev.origin ? prev
        message = isUnassignable prev[1], origin[1]
        @error message, origin[2] if message
      # Create special CONST_ASSIGN token
      token = @makeToken 'CONST_ASSIGN', '='
      @tokens.push token
      return 2  # Consume both = and !
```

### 2. Grammar Changes (`v29/src/grammar.coffee`)

Add CONST_ASSIGN rules to the Assign production around line 132:

```coffeescript
  # Assignment of a variable, property, or index to a value.
  Assign: [
    o 'Assignable = Expression'               , $ast: '@', variable: 1, value: 3
    o 'Assignable = TERMINATOR Expression'    , $ast: '@', variable: 1, value: 4
    o 'Assignable = INDENT Expression OUTDENT', $ast: '@', variable: 1, value: 4
    o 'Assignable CONST_ASSIGN Expression'               , $ast: '@', variable: 1, value: 3, isConstSigil: yes
    o 'Assignable CONST_ASSIGN TERMINATOR Expression'    , $ast: '@', variable: 1, value: 4, isConstSigil: yes
    o 'Assignable CONST_ASSIGN INDENT Expression OUTDENT', $ast: '@', variable: 1, value: 4, isConstSigil: yes
  ]
```

### 3. Backend Changes (`v29/src/backend.coffee`)

Update the Assign case to pass through the isConstSigil flag around line 211:

```coffeescript
# Change the options line from:
options[k] = @$(o[k]) for k in ['operatorToken', 'moduleDeclaration', 'originalContext'] when o[k]?

# To:
options[k] = @$(o[k]) for k in ['operatorToken', 'moduleDeclaration', 'originalContext', 'isConstSigil'] when o[k]?
```

### 4. Nodes Changes (`v29/src/nodes.coffee`)

#### 4a. Update Assign constructor (around line 3313):
```coffeescript
export class Assign extends Base
  constructor: (@variable, @value, @context, options = {}) ->
    super()
    {@param, @subpattern, @operatorToken, @moduleDeclaration, @originalContext = @context, @isConstSigil} = options
    @propagateLhs()
```

#### 4b. Update const/let determination logic (around line 3449):
```coffeescript
          # Simple, predictable const rules:
          # 1. Explicit const sigil (=!) forces const
          # 2. Functions are always const
          # 3. Classes are always const
          # 4. SCREAMING_SNAKE_CASE is const
          # 5. Everything else is let (safe default)
          if @isConstSigil
            declarationKeyword = 'const'
          else if @value instanceof Code or @value instanceof Class
            declarationKeyword = 'const'
          else if varName.match(/^[A-Z][A-Z0-9_]*$/)  # SCREAMING_SNAKE_CASE
            declarationKeyword = 'const'
          else
            declarationKeyword = 'let'
```

### 5. Parser Regeneration

After making grammar changes, regenerate the parser:

```bash
# Create temporary grammar file with module.exports
cd v29
cp src/grammar.coffee src/grammar-temp.coffee
sed -i '' 's/^export {grammar, operators}/module.exports = {grammar, operators}/' src/grammar-temp.coffee

# Generate parser using cs28's coffee and solar-es5
/path/to/cs28/bin/coffee ../solar-es5.coffee -o lib/coffeescript/parser.js src/grammar-temp.coffee

# Clean up
rm src/grammar-temp.coffee
```

Then fix the parser exports at the end of `lib/coffeescript/parser.js`:
```javascript
// Change from CommonJS exports to ES6 exports
function ParserConstructor() { this.yy = {}; }
ParserConstructor.prototype = parserInstance;
parserInstance.Parser = ParserConstructor;
var parser = new ParserConstructor();

export { parser };
export var Parser = function() { return new ParserConstructor(); };
export var parse = function() { return parser.parse.apply(parser, arguments); };
```

### 6. Build Process

```bash
# Compile all source files
cd v29
/path/to/cs28/bin/coffee -c -o lib/coffeescript src/*.coffee

# Fix ES6 imports (add .js extensions)
cd lib/coffeescript
for file in *.js; do
  sed -i '' "s/from '\\.\\//from '.\\//" "$file"
  sed -i '' "s/from '\\.\\/\\([^']*\\)'/from '.\/\\1.js'/g" "$file"
  sed -i '' "s/\\.js\\.js'/.js'/g" "$file"
done

# Fix JSON import assertion in coffeescript.js
sed -i '' "s/import packageJson from '..\/..\/package.json'/import packageJson from '..\/..\/package.json' assert { type: 'json' }/" coffeescript.js
```

## Test Cases

### Basic Test (`test_const_sigil.coffee`)
```coffeescript
# Test the =! const sigil implementation

# 1. Regular assignment (should be let)
normalVar = 42

# 2. Const sigil assignment (should be const)
myConst =! 100

# 3. Function assignment (should be const by default)
myFunc = -> console.log "Hello"

# 4. SCREAMING_SNAKE_CASE (should be const by default)
MY_CONSTANT = 3.14159

# 5. Class assignment (should be const by default)
class MyClass
  constructor: ->

# 6. Testing with destructuring and const sigil
[a, b] =! [1, 2]  # Note: Currently doesn't make a, b const

# 7. Object with const sigil
config =!
  name: "test"
  value: 42

# 8. Normal reassignable variable
counter = 0
counter = counter + 1

# 9. Different value types with const sigil
stringConst =! "immutable string"
numberConst =! 42
boolConst =! true
arrayConst =! [1, 2, 3]
objectConst =! {x: 1, y: 2}

console.log "All tests defined"
```

### Expected Output
```javascript
// Generated by CoffeeScript 2.9.0
(function() {
  let normalVar = 42;
  const myConst = 100;
  const myFunc = function() {
    return console.log("Hello");
  };
  const MY_CONSTANT = 3.14159;
  const MyClass = class MyClass {
    constructor() {}
  };
  [a, b] = [1, 2];  // Note: not const yet
  const config = {
    name: "test",
    value: 42
  };
  let counter = 0;
  counter = counter + 1;
  const stringConst = "immutable string";
  const numberConst = 42;
  const boolConst = true;
  const arrayConst = [1, 2, 3];
  const objectConst = {x: 1, y: 2};
  console.log("All tests defined");
}).call(this);
```

## Known Limitations

1. **Destructuring**: `[a, b] =! [1, 2]` doesn't yet make the destructured variables const. This would require additional changes to the destructuring compilation path.

2. **Chained assignments**: Cannot use const with chained assignments like `a = b =! 5` due to JavaScript limitations.

3. **Compound assignments**: The `=!` sigil only works with simple assignment, not compound operators like `+=!`.

## Testing the Implementation

```bash
# After building, test the implementation
cd /path/to/project
v29/bin/coffee -c test_const_sigil.coffee
cat test_const_sigil.js

# Verify const/let declarations are correct
```

## Troubleshooting

### Common Issues

1. **Parser errors after grammar changes**: Make sure to regenerate the parser and fix the export statements.

2. **Import errors**: Ensure all relative imports have `.js` extensions and JSON imports have the assert clause.

3. **"Unexpected =" error**: The parser wasn't regenerated properly after grammar changes.

4. **Variable declarations missing**: Check that the nodes.coffee changes are in place and the isConstSigil flag is being passed through all layers.

## Alternative Approaches Considered

1. **Analyzing reassignments**: The `willBeReassignedInScope` method was considered but rejected due to complexity and performance concerns.

2. **All capital-starting variables as const**: Rejected because it conflicts with common patterns like `User` classes and `CurrentUser` variables that may need reassignment.

3. **Different sigils**: Considered `:=` or `::=` but `=!` better conveys the "set it and don't change it" semantics.

## Future Enhancements

1. Support destructuring with const sigil properly
2. Add support for const in for...of loops: `for item =! of items`
3. Consider module-level const defaults for imports
4. Add compiler flag to make const the default instead of let
