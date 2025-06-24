# ⚙️ Script de Setup do Servidor Windows – Universo Acadêmico

Este projeto fornece um script PowerShell (`setup.ps1`) que automatiza toda a configuração do ambiente de desenvolvimento em Windows para a plataforma **Universo Acadêmico**, incluindo:

- Clonagem dos repositórios (frontend + backend)
- Instalação de dependências (Node.js, PM2)
- Execução de migrações (AdonisJS)
- Build do frontend (Vite)
- Configuração e inicialização do Nginx
- Aplicação acessível via `http://192.190.90.12`

---

## 🧰 Requisitos

- Windows Server ou Windows 10/11 com permissões administrativas
- PowerShell 5+
- Chocolatey instalado (opcional, mas recomendado)
- Git e Node.js (o script tentará corrigir se estiverem ausentes)

---

## 🚀 Como Usar

1. **Abra o PowerShell como Administrador**
2. Clone este repositório ou salve o `setup.ps1` na máquina
3. Execute o script:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
