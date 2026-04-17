const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Simple route
app.get('/', (req, res) => {
  res.send('Hello World from Node.js app deployed with Terraform and Docker!');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});