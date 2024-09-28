#!/bin/bash

# Create project directory
PROJECT_DIR="secure-server"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Initialize a new Node.js project
npm init -y

# Install required packages
npm install express express-rate-limit helmet

# Create necessary directory structure
mkdir -p public

# Create server.js file
cat <<EOL > server.js
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
const algorithm = 'aes-256-gcm'; // Stronger encryption algorithm
const secretKey = crypto.randomBytes(32); // Use a secure key
const iv = crypto.randomBytes(12); // Initialization vector for GCM

// Function to encrypt data
const encrypt = (text) => {
    const cipher = crypto.createCipheriv(algorithm, secretKey, iv);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    const authTag = cipher.getAuthTag().toString('hex'); // Get authentication tag
    return {
        iv: iv.toString('hex'),
        encryptedData: encrypted,
        authTag: authTag // Include auth tag for integrity
    };
};

// Function to decrypt data
const decrypt = (encryption) => {
    const decipher = crypto.createDecipheriv(algorithm, secretKey, Buffer.from(encryption.iv, 'hex'));
    decipher.setAuthTag(Buffer.from(encryption.authTag, 'hex')); // Set auth tag for verification
    let decrypted = decipher.update(encryption.encryptedData, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
};

// Function to embed additional metadata
const embedMetadata = (data, req) => ({
    data,
    meta: {
        timestamp: new Date().toISOString(),
        requestId: req.ip,
        userAgent: req.headers['user-agent'] // Include user agent for more context
    }
});

// API endpoint for JSON data
app.get('/api/data', (req, res) => {
    if (jsonData) {
        const response = embedMetadata(decrypt(encrypt(JSON.stringify(jsonData))), req);
        res.json(response);
    } else {
        res.status(500).json({ error: 'Failed to load JSON data' });
    }
});

// API endpoint for YAML data
app.get('/api/yaml', (req, res) => {
    if (yamlData) {
        const response = embedMetadata(decrypt(encrypt(YAML.stringify(yamlData))), req);
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
    console.log(\`Server is running on http://localhost:\${PORT}\`);
});
EOL

# Create public/index.html
cat <<EOL > public/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Server</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Welcome to the Secure Server</h1>
        <button id="loadJson">Load JSON Data</button>
        <button id="loadYaml">Load YAML Data</button>
        <pre id="output"></pre>
    </div>
    <script>
        document.getElementById('loadJson').onclick = async () => {
            const response = await fetch('/api/data');
            const data = await response.json();
            document.getElementById('output').innerText = JSON.stringify(data, null, 2);
        };

        document.getElementById('loadYaml').onclick = async () => {
            const response = await fetch('/api/yaml');
            const data = await response.json();
            document.getElementById('output').innerText = JSON.stringify(data, null, 2);
        };
    </script>
</body>
</html>
EOL

# Create public/styles.css
cat <<EOL > public/styles.css
body {
    font-family: Arial, sans-serif;
    background-color: #f4f4f4;
    color: #333;
    text-align: center;
    padding: 20px;
}

.container {
    max-width: 600px;
    margin: auto;
    padding: 20px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

button {
    margin: 10px;
    padding: 10px 15px;
    font-size: 16px;
    cursor: pointer;
}
EOL

# Create data.json and data.yaml files
cat <<EOL > data.json
{
    "message": "This is a JSON response!",
    "status": "success"
}
EOL

cat <<EOL > data.yaml
message: This is a YAML response!
status: success
EOL

# Notify user
echo "Project setup complete. You can now run the server with 'node server.js'."

# Optional: Clean up any duplicates (if necessary)
# This section can be customized further based on your project's requirements

# Exit the script
exit 0
