#!/bin/bash

# Define project name
PROJECT_NAME="secure-node-server"

# Create project directory
mkdir $PROJECT_NAME
cd $PROJECT_NAME

# Initialize a new Node.js project
npm init -y

# Install required packages
npm install express helmet rate-limit-express dotenv

# Create server.js file
cat <<EOF > server.js
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('rate-limit-express');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(express.json());
app.use(rateLimit({ windowMs: 1 * 60 * 1000, max: 100 })); // Limit each IP to 100 requests per windowMs

// Sample endpoint to fetch encrypted JSON data
app.get('/data', (req, res) => {
    const data = {
        message: "This is a secure message.",
        metadata: {
            timestamp: new Date(),
            source: "secure-node-server"
        }
    };

    // Here, implement encryption logic (e.g., using a library)
    res.json(data);
});

// Start the server
app.listen(PORT, () => {
    console.log(\`Server is running on http://localhost:\${PORT}\`);
});
EOF

# Create .env file for environment variables
cat <<EOF > .env
# Environment variables
PORT=3000
EOF

# Run the server
echo "To start the server, run the following command:"
echo "node server.js"

# Instructions to the user
echo "Setup completed. Navigate to $PROJECT_NAME and run 'node server.js' to start the server."
