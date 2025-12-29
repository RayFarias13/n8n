1️⃣ Estrutura de pastas pronta 
waha-n8n-venom/
│
├─ n8n/
│   └─ ... (seu n8n atual, ou vazio se quiser fresh)
│
├─ venom-bot/
│   ├─ bot.js
│   ├─ package.json
│   └─ Dockerfile
│
├─ docker-compose.yml
├─ .env
└─ README.md

venom-bot/bot.js
const express = require('express');
const bodyParser = require('body-parser');
const fetch = require('node-fetch'); // npm install node-fetch@2
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

  client.onMessage(async (message) => {
    if (!process.env.WEBHOOK_TUNNEL_URL) return;
    try {
      await fetch(`${process.env.WEBHOOK_TUNNEL_URL}/webhook/receber-mensagem`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(message),
      });
    } catch (err) {
      console.error('Erro enviando mensagem para n8n:', err.message);
    }
  });
}


-----------------------
venom-bot/package.json

{
  "name": "venom-bot",
  "version": "1.0.0",
  "main": "bot.js",
  "scripts": {
    "start": "node bot.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "body-parser": "^1.20.2",
    "venom-bot": "^4.0.0",
    "node-fetch": "^2.6.12"
  }
}

----------------------------

venom-bot/Dockerfile

FROM node:20

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]


-----------------------------

docker-compose.yml

services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=sqlite
      - DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite
      - PORT=5678
      - WEBHOOK_TUNNEL_URL=${WEBHOOK_TUNNEL_URL}
    volumes:
      - n8n_data:/home/node/.n8n
    command: n8n start --tunnel

  venom-bot:
    build: ./venom-bot
    restart: always
    ports:
      - "3000:3000"
    volumes:
      - ./venom-bot/sessions:/app/sessions
    environment:
      - NODE_ENV=production
      - WEBHOOK_TUNNEL_URL=${WEBHOOK_TUNNEL_URL}

volumes:
  n8n_data:



_________________________
.env

WEBHOOK_TUNNEL_URL=https://fictional-system-7v45x597957q2xjv9-5678.app.github.dev
