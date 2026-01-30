// SERVEUR HTTP NATIF - PAS BESOIN DE NPM
const http = require('http');
const PORT = 5000;

const server = http.createServer((req, res) => {
    // Headers CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    // Gestion OPTIONS pour CORS
    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }
    
    console.log(`${req.method} ${req.url}`);
    
    // Route racine
    if (req.url === '/' && req.method === 'GET') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            success: true,
            message: ' BACKEND PFE ACTIF !',
            routes: ['GET /', 'POST /api/register', 'POST /api/login']
        }));
        return;
    }
    
    // Route inscription
    if (req.url === '/api/auth/register' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            try {
                const data = JSON.parse(body);
                res.writeHead(201, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    success: true,
                    message: ' Compte créé !',
                    user: {
                        email: data.email,
                        id: Date.now(),
                        role: 'client'
                    },
                    token: 'fake-token-' + Date.now()
                }));
            } catch (e) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    success: false,
                    message: 'Données JSON invalides'
                }));
            }
        });
        return;
    }
    
    // Route connexion
    if (req.url === '/api/auth/login' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            const data = JSON.parse(body || '{}');
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                success: true,
                message: ' Connexion réussie !',
                user: {
                    email: data.email,
                    role: 'admin'
                },
                token: 'jwt-token-test-12345'
            }));
        });
        return;
    }
    
    // Route non trouvée
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
        success: false,
        message: `Route non trouvée: ${req.method} ${req.url}`
    }));
});

server.listen(PORT, () => {
    console.log('='.repeat(50));
    console.log(' SERVEUR HTTP NATIF DÉMARRÉ !');
    console.log('='.repeat(50));
    console.log(` Port: ${PORT}`);
    console.log(` URL: http://localhost:${PORT}`);
    console.log('');
    console.log(' ENDPOINTS:');
    console.log('   GET  /');
    console.log('   POST /api/auth/register');
    console.log('   POST /api/auth/login');
    console.log('');
    console.log(' Prêt à recevoir des requêtes...');
});
