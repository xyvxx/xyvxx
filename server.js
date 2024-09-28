const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const YAML = require('yaml');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware for security
app.use(helmet());
app.use(bodyParser.json());
app.use(express.static('public'));

// Rate limiting to prevent abuse
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // Limit each IP to 100 requests per windowMs
});
app.use(limiter);

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

// Encryption settings
const algorithm = 'aes-256-cbc';
const secretKey = crypto.randomBytes(32); // Use a secure key
const iv = crypto.randomBytes(16); // Initialization vector

// Function to encrypt data
const encrypt = (text) => {
    const cipher = crypto.createCipheriv(algorithm, secretKey, iv);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return {
        iv: iv.toString('hex'),
        encryptedData: encrypted
    };
};

// Function to decrypt data
const decrypt = (encryption) => {
    const decipher = crypto.createDecipheriv(algorithm, secretKey, Buffer.from(encryption.iv, 'hex'));
    let decrypted = decipher.update(encryption.encryptedData, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
};

// API endpoint for JSON data
app.get('/api/data', (req, res) => {
    if (jsonData) {
        const response = {
            message: decrypt(encrypt(JSON.stringify(jsonData))), // Encrypting the JSON response
            status: "success",
            meta: {
                timestamp: new Date(),
                requestId: req.ip // Embedding client IP as metadata
            }
        };
        res.json(response);
    } else {
        res.status(500).json({ error: 'Failed to load JSON data' });
    }
});

// API endpoint for YAML data
app.get('/api/yaml', (req, res) => {
    if (yamlData) {
        const response = {
            message: decrypt(encrypt(YAML.stringify(yamlData))), // Encrypting the YAML response
            status: "success",
            meta: {
                timestamp: new Date(),
                requestId: req.ip // Embedding client IP as metadata
            }
        };
        res.json(response);
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

