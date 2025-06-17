Write-Host "🔧 Instalando Chocolatey e pacotes essenciais..."

Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install git nodejs-lts nginx mysql pm2.install -y

# Clonar os projetos
cd C:\vagrant
git clone https://github.com/JordaoNhanga15/universo-academico.git
git clone https://github.com/JordaoNhanga15/admin-portal-universidade-template.git

# Instalar dependências do frontend
cd C:\vagrant\universo-academico
npm install
npm run build

# Instalar dependências do backend
cd C:\vagrant\admin-portal-universidade-template
npm install
npx node ace migration:run
pm2 start server.js --name universo-backend
pm2 save

# Configurar nginx
$nginxConf = @"
server {
    listen       80;
    server_name  localhost;

    root   C:/vagrant/universo-academico/dist;
    index  index.html;

    location / {
        try_files \$uri /index.html;
    }

    location /api {
        proxy_pass         http://localhost:3333;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
"@

$nginxConf | Set-Content "C:\tools\nginx-*\conf\nginx.conf"

# Start nginx
Start-Process -FilePath "C:\tools\nginx-*\nginx.exe"

Write-Host "✅ Setup completo. Acesse: http://192.190.90.12"
