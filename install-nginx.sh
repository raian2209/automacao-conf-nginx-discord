#!/bin/bash

# ==============================================================================
# Script para automatizar a configuração de um servidor web com Nginx em Ubuntu
#
# Funcionalidades:
# 1. Atualiza o sistema operacional.
# 2. Verifica se o Nginx está instalado.
# 3. Se não estiver instalado, ele instala, inicia e habilita o serviço.
# 4. Cria uma página HTML simples como padrão.
# 5. Se o Nginx já estiver instalado, ele não faz nada.
#
# É necessário executar este script com privilégios de superusuário (root ou com sudo).
# ==============================================================================

# Garante que o script pare se algum comando falhar
set -e

# --- Passo 1: Atualizar o sistema ---
echo "----------------------------------------------------"

# --- Passo 2: Checar a existência do Nginx ---
# Usamos 'dpkg -s' para verificar o status do pacote.
# A saída e os erros são redirecionados para /dev/null para não poluir o terminal.
# O script continuará para o bloco 'if' apenas se o comando falhar (ou seja, se o nginx não estiver instalado).


echo "----------------------------------------------------"
echo "Script Configuração Nginx Iniciado."
if ! dpkg -s nginx &> /dev/null; then

    # --- Passo 3: Instalar, iniciar e habilitar o Nginx ---
    echo "INFO: Nginx não encontrado. Iniciando a instalação..."
  
    sudo add-apt-repository universe -y

    # 2. Atualiza a lista de pacotes para incluir o novo repositório
    sudo apt-get update

    # 3. Instala ambos os pacotes
    sudo apt-get install -y nginx inotify-tools 
    
    echo "INFO: Nginx instalado. Iniciando e habilitando o serviço..."
    # Inicia o serviço do Nginx imediatamente
    sudo systemctl start nginx
    
    # Habilita o Nginx para iniciar automaticamente com o sistema
    sudo systemctl enable nginx
    
    echo "INFO: Serviço Nginx iniciado e configurado para inicialização automática."
    echo "----------------------------------------------------"

    # --- Passo 4: Configurar uma página web simples ---
    echo "INFO: Criando uma página web de exemplo em /var/www/html/index.html..."

    # Usamos um "Here Document" (<<EOF) para criar o arquivo HTML de forma limpa.
    # O comando 'sudo tee' é usado para escrever o conteúdo no arquivo com permissões de root.
    sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bem-vindo ao meu Servidor Web!</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f0f2f5; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; text-align: center; }
        .container { background-color: #ffffff; padding: 40px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        p { color: #666; font-size: 1.2em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Servidor Web Configurado com Sucesso!</h1>
        <p>Este site está rodando em um servidor Nginx, configurado automaticamente por um script shell.</p>
        <p>$(date)</p>
    </div>
</body>
</html>
EOF

    echo "INFO: Página de exemplo criada com sucesso!"
    echo "----------------------------------------------------"
    echo "SUCESSO: O servidor web Nginx está instalado e rodando."

else
    # --- Passo 5: Se o Nginx já estiver instalado, não faz nada ---
    echo "INFO: O Nginx já está instalado no sistema. Nenhuma ação foi tomada."
fi

echo "----------------------------------------------------"
echo "Script Configuração Nginx finalizado."


# --- Passo 6: Criar o script de monitoramento ---
echo "INFO: Criando o script de monitoramento"
bash ./Config-nginx.sh
echo "INFO: Finalizando o script de monitoramento"
