const express = require('express');
const bodyParser = require('body-parser');
const venom = require('venom-bot');

const app = express();
app.use(bodyParser.json());

let client;

venom
  .create({
    session: 'n8n',
    multidevice: true
  })
  .then((c) => {
    client = c;
    startServer();
  })
  .catch((err) => console.error(err));

function startServer() {
  app.post('/send', async (req, res) => {
    const { chatId, message } = req.body;
    try {
      await client.sendText(chatId, message);
      res.json({ status: 'success' });
    } catch (err) {
      res.status(500).json({ status: 'error', error: err.message });
    }
  });

  app.listen(3000, () => console.log('Venom-Bot HTTP API rodando na porta 3000'));
}
