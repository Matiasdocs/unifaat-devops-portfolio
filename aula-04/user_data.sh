#!/bin/bash
# user_data.sh - Setup automatico da API TechNova (Aula 04)
set -e

LOGFILE=/var/log/technova-setup.log
echo "=== Iniciando setup TechNova $(date) ===" > $LOGFILE

echo "Atualizando pacotes..." >> $LOGFILE
yum update -y >> $LOGFILE 2>&1

echo "Instalando Git..." >> $LOGFILE
yum install -y git >> $LOGFILE 2>&1

echo "Instalando Node.js 18..." >> $LOGFILE
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash - >> $LOGFILE 2>&1
yum install -y nodejs >> $LOGFILE 2>&1
echo "Node instalado: $(node --version)" >> $LOGFILE

echo "Criando aplicacao technova-api..." >> $LOGFILE
mkdir -p /home/ec2-user/technova-api
cd /home/ec2-user/technova-api

cat > package.json << 'EOF'
{
  "name": "technova-api",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "4.18.2"
  }
}
EOF

cat > server.js << 'EOF'
const express = require('express');
const os = require('os');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'TechNova API - Rodando na AWS!',
    hostname: os.hostname(),
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'technova-api' });
});

app.get('/orders', (req, res) => {
  res.json({
    orders: [
      { id: 1, product: 'Widget A', status: 'shipped' },
      { id: 2, product: 'Widget B', status: 'processing' },
      { id: 3, product: 'Widget C', status: 'delivered' }
    ]
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`TechNova API rodando na porta ${PORT}`);
});
EOF

echo "Instalando dependencias..." >> $LOGFILE
npm install --production >> $LOGFILE 2>&1

chown -R ec2-user:ec2-user /home/ec2-user/technova-api

echo "Iniciando API..." >> $LOGFILE
sudo -u ec2-user nohup node /home/ec2-user/technova-api/server.js > /home/ec2-user/technova-api/app.log 2>&1 &

echo "=== Setup concluido $(date) ===" >> $LOGFILE