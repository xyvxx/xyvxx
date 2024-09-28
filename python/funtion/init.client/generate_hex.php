<?php
// Generate a random hexadecimal string
function generateRandomHex($length = 16) {
    return bin2hex(random_bytes($length / 2));
}

// Output the random hex string
echo generateRandomHex();
?>
