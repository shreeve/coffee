# CoffeeScript 2.9.0

## Architecture (CS29)

This version of CoffeeScript (CS29) uses the Solar parser generator in "Solar mode" with pure data directives instead of direct AST node creation, achieving complete functional parity with CS28 (minus JSX).

### Parser Architecture

CS29 employs a clean two-stage compilation process:

1. **Parser Stage**: Solar parser generator processes `src/syntax.coffee` to create a parser that outputs pure data directives
2. **ES5 Backend**: `src/es5.coffee` transforms these directives into CoffeeScript AST nodes

### Grammar to AST Mapping

The system transforms 97 grammar types into 68 unique AST node types through an elegant directive system:

```
Grammar Type (1 of 97) → Rule (1 of 404) → Directive → AST Node (1 of 68)
                                    ↓
                            es5.coffee handler (1 of 68 handlers)
```

### Directive Types

CS29 uses five types of directives to control AST generation:

1. **Direct AST Creation** (`$ast: 'ClassName'`) - Creates a specific AST node type
   - Example: `o 'Expression', $ast: 'Arg', name: 1` creates an `Arg` node

2. **Type Name Inheritance** (`$ast: '@'`) - Uses the grammar type name as the AST node type
   - Example: `o 'CLASS', $ast: '@'` creates a `Class` node

3. **Operations** (`$ops`) - Performs array/value manipulations
   - Example: `o 'ArgList , Arg', $ops: 'array', append: [1, 3]`

4. **Array Creation** (`$arr`) - Creates arrays directly
   - Example: `o 'ImportSpecifier', $arr: [1]`

5. **Pass-through** (`$use`) - Returns the referenced value unchanged
   - Example: `o 'INDENT ExportSpecifierList OptComma OUTDENT', $use: 2`

### ES5 Handler Organization

The 68 handlers in `es5.coffee` are optimized by frequency of use:

1. **Core Expressions** (Very High) - Value, Literal, Assign, Call, Op
2. **Control Flow** (High) - Block, Root, If, While, For, Return
3. **Functions & Classes** (Medium-High) - Code, Param, FuncGlyph, Class
4. **Data Structures** (Medium) - Obj, Arr, Range, Slice, Expansion
5. **Common Literals** (Medium) - BooleanLiteral, ThisLiteral, NullLiteral
6. **String Interpolation** (Low-Medium) - StringWithInterpolations, Interpolation
7. **Special Operations** (Low) - Switch, Super, Existence, Parens
8. **Error Handling** (Low) - Try, Catch, Throw
9. **Modules** (Low) - Import/Export variants (11 handlers)
10. **Advanced/Rare** (Very Low) - YieldReturn, MetaProperty, Elision, etc.

### Complete Feature Parity

CS29 has achieved 100% functional parity with CS28 (excluding JSX):

✅ **All Supported Features:**
- All expressions and statements
- All control flow constructs
- Classes and inheritance
- Functions (regular, bound, async, generators)
- Destructuring assignments
- Template literals and interpolation
- Import/Export (all ES6 variants)
- Spread/rest operators
- Meta properties (new.target, import.meta)
- Dynamic imports
- Tagged template literals
- Yield/await returns

### Key Files

- `src/syntax.coffee`: Grammar definition with Solar directives (97 types, 404 rules)
- `src/es5.coffee`: ES5 backend with 68 optimized AST handlers
- `src/nodes.coffee`: AST node class definitions (97 classes total)
- `lib/coffeescript/parser.js`: Generated parser from Solar

### Architecture Benefits

**Cleaner Separation**: Pure data directives vs mixed code/data in traditional parsers
**Better Performance**: Handlers organized by frequency for optimal cache usage
**Easier Maintenance**: Most handlers are clean one-liners
**Complete Coverage**: Every language feature fully supported
**Production Ready**: Thoroughly tested and debugged
