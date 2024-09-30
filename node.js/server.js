node server.js
const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const YAML = require('yaml');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware for security
app.use(helmet());
app.use(bodyParser.json());
app.use(express.static('public'));

// Load JSON data
let jsonData;
try {
    jsonData = JSON.parse(fs.readFileSync('data.json', 'utf8'));
} catch (error) {
    console.error('Error loading JSON data:', error);
}

// Load YAML data
let yamlData;
try {
    yamlData = YAML.parse(fs.readFileSync('data.yaml', 'utf8'));
} catch (error) {
    console.error('Error loading YAML data:', error);
}

// API endpoint for JSON data
app.get('/api/data', (req, res) => {
    if (jsonData) {
        res.json(jsonData);
    } else {
        res.status(500).json({ error: 'Failed to load JSON data' });
    }
});

// API endpoint for YAML data
app.get('/api/yaml', (req, res) => {
    if (yamlData) {
        res.json(yamlData);
    } else {
        res.status(500).json({ error: 'Failed to load YAML data' });
    }
});

// Home route
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/public/index.html');
});

// Start server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
