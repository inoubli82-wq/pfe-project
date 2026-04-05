const fs = require('fs');
let code = fs.readFileSync('backend/controllers/partnerExportController.js', 'utf8');

code = code.split('.json({ success: false, message: "Action failed" })\r\n * PUT').join('.json({ success: false, message: "Action failed" });\n  }\n};\n\n/**\n * PUT');

code = code.split('.json({ success: false, message: "Action failed" })\n * PUT').join('.json({ success: false, message: "Action failed" });\n  }\n};\n\n/**\n * PUT');

fs.writeFileSync('backend/controllers/partnerExportController.js', code);
