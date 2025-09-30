# CoffeeScript 2.9.0

## Architecture (CS29)

This version of CoffeeScript (CS29) uses the Solar parser generator in "Solar mode" with data directives instead of direct AST node creation.

### Parser Architecture

CS29 employs a two-stage compilation process:

1. **Parser Stage**: Solar parser generator processes `src/syntax.coffee` to create a parser that outputs data directives
2. **ES5 Backend**: `src/es5.coffee` transforms these directives into CoffeeScript AST nodes

### Grammar to AST Mapping

The system transforms 97 grammar types into 60 unique AST node types through an elegant directive system:

```
Grammar Type (1 of 97) → Rule (1 of 404) → Directive → AST Node (1 of 60)
                                    ↓
                            es5.coffee handler (1 of 62 cases)
```

### Directive Types

CS29 uses five types of directives to control AST generation:

1. **Direct AST Creation** (`$ast: 'ClassName'`) - 156 rules
   - Creates a specific AST node type
   - Example: `o 'Expression', $ast: 'Arg', name: 1` creates an `Arg` node

2. **Type Name Inheritance** (`$ast: '@'`) - 75 rules
   - Uses the grammar type name as the AST node type
   - Example: `o 'CLASS', $ast: '@'` creates a `Class` node

3. **Operations** (`$ops`) - 45 rules
   - Performs array/value manipulations
   - Example: `o 'ArgList , Arg', $ops: 'array', append: [1, 3]`

4. **Array Creation** (`$arr`) - 18 rules
   - Creates arrays directly
   - Example: `o 'ImportSpecifier', $arr: [1]`

5. **Pass-through** (`$use`) - 68 rules
   - Returns the referenced value unchanged
   - Example: `o 'INDENT ExportSpecifierList OptComma OUTDENT', $use: 2`

### Why 97 Grammar Types ≠ 97 AST Types

The mapping is many-to-one because:

- Multiple grammar rules often create the same AST type (e.g., many operators create `Op` nodes)
- Some rules use operations (`$ops`, `$arr`, `$use`) rather than creating new nodes
- Rules with `$ast: '@'` reuse their grammar type name
- The system eliminates redundancy through shared AST types

### Key Files

- `src/syntax.coffee`: Grammar definition with Solar directives (97 types, 404 rules)
- `src/es5.coffee`: ES5 backend that processes directives into AST nodes (62 handlers)
- `src/nodes.coffee`: AST node class definitions
- `lib/coffeescript/parser.js`: Generated parser from Solar

### Recent Fixes (CS29)

- Fixed `class @Inner` syntax by removing direct `ThisProperty` from `Value` rules
- Changed import assertions from `WITH` to `ASSERT` to match CS28
- Added missing Import AST handlers (`ImportSpecifierList`, `ImportSpecifier`)
- Fixed `loop` construct by properly assigning body to `While` nodes
- Removed dead code for Root rule wrapping (not needed in Solar mode)
