#!/usr/bin/env node

// Check for ES6 support
try {
  new Function('const {a} = {a: 1}')();
} catch (error) {
  console.error('Your JavaScript runtime does not support some features used by the coffee command. Please use Node 6 or later.');
  process.exit(1);
}

import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const potentialPaths = [
  path.join(process.cwd(), 'node_modules/coffeescript/lib/coffeescript'),
  path.join(process.cwd(), 'node_modules/coffeescript/lib/coffee-script'),
  path.join(process.cwd(), 'node_modules/coffee-script/lib/coffee-script'),
  path.join(__dirname, '../lib/coffeescript')
];

// Use async/await for dynamic imports
(async () => {
  for (const potentialPath of potentialPaths) {
    if (fs.existsSync(potentialPath)) {
      const command = await import(potentialPath + '/command.js');
      command.run();
      break;
    }
  }
})();
