#!/bin/bash
set -e # Faz o script parar se qualquer comando falhar

# --- VERIFICAÇÕES INICIAIS ---

# 1. Verifica se o script está sendo executado com sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "ERRO: Este script precisa ser executado com sudo." >&2
  exit 1
fi

# 2. Verifica se a variável de ambiente foi passada (usando o -E)
if [ -z "$DISCORD_WEBHOOK_URL" ]; then
  echo "ERRO: A variável de ambiente DISCORD_WEBHOOK_URL não está definida." >&2
  echo "Execute: export DISCORD_WEBHOOK_URL=... e rode este script com 'sudo -E ./automat-orq.sh'"
  exit 1
fi


# --- DEFINIÇÃO DE CAMINHOS ---
SERVICE_FILE="/etc/systemd/system/nginx-log-monitor.service"
ENV_FILE="/etc/nginx-monitor-env"


# --- LÓGICA DE CRIAÇÃO ---

# 3. Cria o arquivo de ambiente se ele não existir
if [ ! -f "$ENV_FILE" ]; then
    echo "INFO: Criando arquivo de ambiente em $ENV_FILE..."
    # Usa tee com sudo para garantir a permissão de escrita em /etc
    echo "DISCORD_WEBHOOK_URL=$DISCORD_WEBHOOK_URL" | tee "$ENV_FILE" > /dev/null
else
    echo "INFO: Arquivo de ambiente $ENV_FILE já existe. Pulando."
fi

# 4. Cria o arquivo de serviço se ele não existir
if [ ! -f "$SERVICE_FILE" ]; then
    echo "INFO: Criando arquivo de serviço em $SERVICE_FILE..."
    # Usa tee com sudo para garantir a permissão de escrita em /etc/systemd/system
    tee "$SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=Real-time Nginx Error Log Monitor
After=network.target

[Service]
# Garanta que este caminho para o script de monitoramento está correto!
ExecStart=/home/ubuntu/automacao-conf-nginx-discord/monitor_nginx_log.sh
Restart=always
User=ubuntu
EnvironmentFile=$ENV_FILE

[Install]
WantedBy=multi-user.target
EOF
else
    echo "INFO: Arquivo de serviço $SERVICE_FILE já existe. Pulando."
fi


# --- HABILITAÇÃO DO SERVIÇO ---
echo "INFO: Recarregando systemd e habilitando o serviço..."
systemctl daemon-reload
systemctl enable --now nginx-log-monitor.service

echo "----------------------------------------------------"
echo "SUCESSO! Serviço de monitoramento configurado e ativo."
echo "Para verificar o status, use: sudo systemctl status nginx-log-monitor.service"
echo "----------------------------------------------------"