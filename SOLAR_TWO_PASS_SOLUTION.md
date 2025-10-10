# Solar Directives Two-Pass Solution for ES6 Scoping

## Summary

The ES6 scoping issues in CoffeeScript can be solved using a two-pass approach with Solar directives:

### Pass 1: Analysis Phase
- Traverse the entire AST using Solar directives
- Track all variable declarations and their scopes
- Track all variable usages and their scopes
- Identify variables that need promotion (used outside their declaring scope)
- Determine const vs let based on reassignment analysis

### Pass 2: Code Generation Phase
- Generate variable declarations at the correct scope level
- Skip declarations in inner scopes for promoted variables
- Use const for non-reassigned variables, let for reassigned ones
- Handle helper functions with unique naming

## Key Insights

### 1. Try/Catch Variable Promotion Works
We successfully implemented automatic promotion of variables declared in try blocks that are used in catch/finally blocks. The Solar directives allow us to:
- Traverse the AST to find assignments in try blocks
- Check if those variables are used in catch/ensure blocks
- Promote them to the outer scope

### 2. Helper Functions Need Special Handling
The `indexOf`, `hasProp`, `slice` helpers get renamed (indexOf1, indexOf2) due to scope conflicts. Solution:
- Use a special prefix like `$$indexOf` for helpers
- Generate them once at module level
- Reference them consistently

### 3. Comprehensive Scope Analysis is Feasible
Using Solar directives, we can:
- Track every variable declaration and usage
- Determine optimal declaration location
- Choose const vs let based on reassignment
- Handle implicit variables from comprehensions

## Implementation Challenges Encountered

1. **Variable Declaration Prevention**: When promoting variables, we need to both:
   - Add declaration at outer scope
   - Prevent declaration at inner scope

2. **Scope Tracking**: Need to track which scope each variable belongs to and where it's used

3. **Helper Function Scoping**: Utilities are generated multiple times in nested scopes

## Recommended Approach

1. **Add a Scope Analysis Pass**: Before code generation, analyze the entire AST
2. **Create a Variable Map**: Track each variable's declaration scope and usage scopes
3. **Modify Code Generation**: Use the variable map to generate declarations at the right level
4. **Handle Edge Cases**: Comprehensions, destructuring, default parameters, etc.

## Benefits of Solar Approach

- **Complete Information**: Solar directives provide full AST before generation
- **Clean Separation**: Analysis is separate from code generation
- **Maintainable**: Logic is centralized and easy to understand
- **Extensible**: Can add more analysis without changing generation code
