#!/bin/bash

# Rebuild ES6 CoffeeScript
echo "🔨 Building cs30 with ES6 output..."

# Step 1: Compile cs30 using cs29 with ES6 mode
cd /Users/shreeve/Data/Code/coffee/cs29
CS3=1 npm run build6

# Step 2: Apply all fixes
cd /Users/shreeve/Data/Code/coffee
echo "🔧 Applying ES6 fixes..."

# Fix export IIFE patterns
node fix-export-iife.js

# Fix ref scope issues
node fix-ref-scope.js

# Fix Array.prototype patterns
node fix-array-prototype.js

# Fix destructuring
node fix-destructuring.js

# Fix remaining issues
node fix-all-es6.js

# Step 3: Test results
echo ""
echo "📋 Test Results:"
cd cs30/lib/coffeescript
for file in *.js; do
  echo -n "$file: "
  node -e "import('./$file').then(() => console.log('✅')).catch(e => console.log('❌'))" 2>/dev/null
done

echo ""
echo "✨ ES6 build complete!"
