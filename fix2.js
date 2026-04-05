const fs = require('fs');
let code = fs.readFileSync('backend/controllers/partnerExportController.js', 'utf8');

code = code.replace(/(\.json\(\{ success: false, message: "Action failed" \}))\s*\*\s*PUT/g, '\;\n  }\n};\n\n/**\n * PUT');

fs.writeFileSync('backend/controllers/partnerExportController.js', code);
