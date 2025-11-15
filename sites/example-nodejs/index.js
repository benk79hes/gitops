const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('<h1>Hello from Node.js App</h1><p>This is an example Node.js application hosted with Traefik and Let\'s Encrypt SSL.</p>');
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
