#!/bin/bash

SERVICE_FILE1="/etc/systemd/system/nginx-log-monitor.service"
PATH_ENV="/etc/nginx-monitor-env"

if [ -f "$SERVICE_FILE1" ] ; then
  echo "INFO:  o arquivo de configuração já foi encontrado."
  echo "      - Script: $SERVICE_FILE1"
  echo "INFO: Presumindo que o serviço já está configurado. Nenhuma ação será tomada."
  # Sai do script com sucesso (código 0), pois não fazer nada é o comportamento esperado.
  exit 0
fi

if [ -f "$PATH_ENV" ] || [ -z "$DISCORD_WEBHOOK_URL" ]; then
  echo "INFO:  o arquivo de ambiente foi encontrado ou a variável DISCORD_WEBHOOK_URL não está definida."
  echo "      - Script: $PATH_ENV"
  echo "INFO: Criando o arquivo de ambiente."
  exit 0
fi

cat > "$PATH_ENV" << EOF
DISCORD_WEBHOOK_URL=$DISCORD_WEBHOOK_URL
EOF


cat > "$SERVICE_FILE1" << EOF
[Unit]
Description=Real-time Nginx Error Log Monitor
After=network.target

[Service]
# O caminho para o nosso novo script de monitoramento
ExecStart=/home/ubuntu/automacao-conf-nginx-discord/monitor_nginx_log.sh

# Política de reinicialização: se o script falhar por qualquer motivo, reinicie-o.
Restart=always

# Usuário que executará o script. 'www-data' ou 'ubuntu' são boas opções.
User=ubuntu

# Arquivo que contém a variável de ambiente com o segredo
EnvironmentFile=/home/ubuntu/automacao-conf-nginx-discord/monitor_nginx_log_env

[Install]
WantedBy=multi-user.target
EOF