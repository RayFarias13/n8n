#!/bin/bash
# ===============================
# Script para iniciar n8n + Venom-Bot
# ===============================

# Carrega variáveis do .env
export $(grep -v '^#' .env | xargs)

echo "Iniciando n8n + Venom-Bot..."
echo "WEBHOOK_TUNNEL_URL=$WEBHOOK_TUNNEL_URL"

# Iniciar n8n em background
echo "Iniciando n8n..."
n8n start --tunnel &
N8N_PID=$!

# Aguardar 5 segundos antes de iniciar Venom-Bot
sleep 5

# Entrar na pasta venom-bot e iniciar o bot
echo "Iniciando Venom-Bot..."
cd venom-bot
npm start &
VENOM_PID=$!

# Espera que ambos rodem até o usuário encerrar
wait $N8N_PID $VENOM_PID
