Write-Host "🔧 Iniciando setup..."

# Permitir execução e configurar protocolo de segurança
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Instalar Chocolatey se necessário
if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Write-Host "💡 Instalando Chocolatey..."
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
} else {
    Write-Host "✔️ Chocolatey já instalado."
}

# Instalar ferramentas essenciais
Write-Host "🔧 Instalando ferramentas: Git, Node.js LTS, Nginx, MySQL, PM2..."
choco install -y git nodejs-lts nginx mysql pm2.install

# Clonar os projetos
Write-Host "📥 Clonando repositórios..."
cd C:\vagrant
git clone https://github.com/JordaoNhanga15/universo-academico.git
git clone https://github.com/JordaoNhanga15/admin-portal-universidade-template.git

# Instalar frontend
Write-Host "🛠 Instalando dependências do frontend (Vite)..."
cd C:\vagrant\universo-academico
npm install
npm run build

# Instalar backend
Write-Host "🛠 Instalando dependências do backend (AdonisJS)..."
cd C:\vagrant\admin-portal-universidade-template
npm install
npx node ace migration:run
pm2 start server.js --name universo-backend
pm2 save

# Configurar Nginx
Write-Host "🌐 Configurando Nginx..."
$nginxRoot = (Get-ChildItem -Directory -Path "C:\tools" | Where-Object { $_.Name -like "nginx*" } | Select-Object -First 1).FullName
$nginxConfPath = Join-Path $nginxRoot "conf\nginx.conf"

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

$nginxConf | Set-Content -Path $nginxConfPath -Force

# Iniciar Nginx
Write-Host "🚀 Iniciando Nginx..."
Start-Process "$nginxRoot\nginx.exe"

Write-Host "✅ Setup completo. Acesse: http://192.190.90.12"

