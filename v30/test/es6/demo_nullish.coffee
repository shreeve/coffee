# Demo: Nullish Coalescing Operator

# Basic usage
x = y ? "default"

# Chained
result = a ? b ? c ? "final"

# With function calls
data = getData() ? {}

# With property access
value = obj.prop ? 0

# In expressions
sum = (x ? 0) + (y ? 0)

# With arrays
item = arr[index] ? defaultItem

# Export with nullish coalescing
export helper = config ? {}
