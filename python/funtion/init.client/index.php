<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Random Hexadecimal Generator</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin: 50px;
        }
        #result {
            margin-top: 20px;
            font-size: 1.5em;
            color: #333;
        }
        button {
            padding: 10px 15px;
            font-size: 1em;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <h1>Random Hexadecimal String Generator</h1>
    <button onclick="generateHex()">Generate Random Hex</button>
    <div id="result"></div>

    <script>
        function generateHex() {
            fetch('generate_hex.php')
                .then(response => response.text())
                .then(data => {
                    document.getElementById('result').innerText = data;
                })
                .catch(error => {
                    console.error('Error:', error);
                });
        }
    </script>
</body>
</html>
