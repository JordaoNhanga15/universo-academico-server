#!/usr/bin/env bash
set -e

echo "🚀 Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

echo "📦 Instalando Node.js, npm e PM2..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2

echo "🗄 Instalando MySQL Server..."
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt install -y mysql-server

echo "🔧 Instalando Nginx..."
sudo apt install -y nginx
sudo ufw allow 'Nginx Full'

echo "📁 Clonando o projeto frontend..."
cd /home/vagrant/workspace
git clone https://github.com/JordaoNhanga15/universo-academico.git
cd universo-academico
npm install
npm run build

echo "📁 Clonando o projeto backend..."
cd /home/vagrant/workspace
git clone https://github.com/JordaoNhanga15/admin-portal-universidade-template.git
cd admin-portal-universidade-template
npm install
node ace migration:run
pm2 start server.js --name universo-backend
pm2 save

echo "🔧 Configurando Nginx..."
sudo tee /etc/nginx/sites-available/universo <<EOF
server {
    listen 80;
    server_name 192.190.90.12;

    root /home/vagrant/workspace/universo-academico/dist;
    index index.html;

    location / {
        try_files \$uri /index.html;
    }

    location /api {
        proxy_pass http://localhost:3333;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/universo /etc/nginx/sites-enabled/universo
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

echo "✅ Provisionamento completo. Acesse via http://192.190.90.12"
