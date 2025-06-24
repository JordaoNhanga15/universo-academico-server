Write-Host "🚀 Iniciando o setup do servidor..."

# Garante o protocolo de segurança para Chocolatey e downloads
Set-ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Garante que os caminhos estejam acessíveis
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\nodejs;C:\ProgramData\chocolatey\bin;C:\Users\vagrant\AppData\Roaming\npm"

# === Validação das ferramentas ===

function Test-Command($name) {
    return Get-Command $name -ErrorAction SilentlyContinue
}

if (-not (Test-Command git)) { Write-Host "❌ Git não está disponível. Verifique o PATH."; exit 1 }
if (-not (Test-Command npm)) { Write-Host "❌ npm não está disponível. Verifique o PATH."; exit 1 }
if (-not (Test-Command pm2)) { Write-Host "❌ pm2 não encontrado. Instalando via npm..."; npm install -g pm2 }

# === Clonagem dos repositórios ===

$workspace = "C:\workspace"
if (!(Test-Path $workspace)) {
    New-Item -ItemType Directory -Path $workspace | Out-Null
}

Set-Location $workspace

if (!(Test-Path "universo-academico")) {
    Write-Host "[CLONE] Clonando frontend..."
    git clone https://github.com/JordaoNhanga15/universo-academico.git
} else {
    Write-Host "[CLONE] Repositório frontend já existe."
}

if (!(Test-Path "admin-portal-universidade-template")) {
    Write-Host "[CLONE] Clonando backend..."
    git clone https://github.com/JordaoNhanga15/admin-portal-universidade-template.git
} else {
    Write-Host "[CLONE] Repositório backend já existe."
}

# === Build do Frontend ===

Write-Host "[BUILD] Configurando frontend..."
Set-Location "$workspace\universo-academico"
npm install
npm run build

# === Setup do Backend ===

Write-Host "[BUILD] Configurando backend..."
Set-Location "$workspace\admin-portal-universidade-template"
npm install
npx.cmd node ace migration:run
pm2 start server.js --name universo-backend
pm2 save

# === Configurar Nginx ===

Write-Host "[CONFIG] Configurando Nginx..."

$nginxRoot = "C:\nginx\nginx-1.24.0"
$nginxExe = "$nginxRoot\nginx.exe"
$confPath = "$nginxRoot\conf\nginx.conf"
$frontendDist = "C:/workspace/universo-academico/dist"

if (Test-Path $nginxExe) {
    @"
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;

        root   $frontendDist;
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
}
"@ | Set-Content -Path $confPath -Force

    Write-Host "[NGINX] Reiniciando nginx..."
    Stop-Process -Name nginx -ErrorAction SilentlyContinue
    Start-Process $nginxExe
} else {
    Write-Host "❌ Nginx não encontrado no caminho: $nginxExe"
    exit 1
}

Write-Host "✅ Setup concluído com sucesso!"
Write-Host "🌐 Acesse: http://192.190.90.12"
