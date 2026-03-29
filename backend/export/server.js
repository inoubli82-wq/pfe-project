const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const exportRoutes = require('./routes/exportRoutes');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/api/export-data', exportRoutes);

// Route de test
app.get('/test', (req, res) => {
  res.json({ message: 'Backend fonctionne !' });
});

// Démarrer le serveur
app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur http://localhost:${PORT}`);
  console.log(`📝 Test API: http://localhost:${PORT}/test`);
  console.log(`📦 API Export: http://localhost:${PORT}/api/export-data`);
});