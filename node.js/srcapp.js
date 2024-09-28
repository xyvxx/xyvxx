// src/app.js
const express = require('express');
const rateLimit = require('express-rate-limit');
const routes = require('./routes/index');

const app = express();
const PORT = process.env.PORT || 3000;

// Apply rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // limit each IP to 100 requests per windowMs
});

// Apply to all requests
app.use(limiter);

// Use routes
app.use('/', routes);

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
