#!/bin/bash


PATH_ENV="/etc/nginx-monitor-env"

if [ -f "$PATH_ENV" ] || [ -z "$DISCORD_WEBHOOK_URL" ]; then
  echo "INFO:  o arquivo de ambiente foi encontrado ou a variável DISCORD_WEBHOOK_URL não está definida."
  echo "      - Script: $PATH_ENV"
  echo "INFO: Criando o arquivo de ambiente."
  exit 0
fi

cat > "$PATH_ENV" << EOF
DISCORD_WEBHOOK_URL=$DISCORD_WEBHOOK_URL
EOF
