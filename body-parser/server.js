const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const YAML = require('yaml');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());
app.use(express.static('public'));

// Load JSON data
const jsonData = JSON.parse(fs.readFileSync('data.json', 'utf8'));

// Load YAML data
const yamlData = YAML.parse(fs.readFileSync('data.yaml', 'utf8'));

// API endpoint for JSON data
app.get('/api/data', (req, res) => {
    res.json(jsonData);
});

// API endpoint for YAML data
app.get('/api/yaml', (req, res) => {
    res.json(yamlData);
});

// Home route
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/public/index.html');
});

// Start server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
