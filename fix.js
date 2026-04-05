const fs = require('fs');
let code = fs.readFileSync('backend/controllers/partnerExportController.js', 'utf8');

// Fix accidental }), );
code = code.replace(/\{ success: false, message: "Action failed" \}\),\s*\);/g, '{ success: false, message: "Action failed" });');

// Fix missing end brackets for catch blocks
code = code.replace(/\.json\(\{ success: false, message: "Action failed" \}\)\s*\/\*/g, '.json({ success: false, message: "Action failed" });\n  }\n};\n\n/**');

fs.writeFileSync('backend/controllers/partnerExportController.js', code);
