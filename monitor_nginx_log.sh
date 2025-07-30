#!/bin/bash

# Este script monitora o log de status do Nginx e envia um alerta ao Discord
# apenas quando um código de status de erro é detectado.
# VERSÃO COM ENVIO ROBUSTO DE JSON (V5)

LOG_FILE="/var/log/nginx_status.log"

if [ -z "$DISCORD_WEBHOOK_URL" ]; then
    logger -t nginx_smart_monitor "ERRO: A variável DISCORD_WEBHOOK_URL não está configurada."
    exit 1
fi

logger -t nginx_smart_monitor "INFO: Monitoramento do arquivo '$LOG_FILE' iniciado."

# Pausa o script aqui até que o arquivo seja modificado.
while inotifywait --quiet -e modify "$LOG_FILE"; do
    
    LAST_LOG_LINE=$(tail -n 1 "$LOG_FILE")
    STATUS_CODE=$(echo "$LAST_LOG_LINE" | awk '{print $NF}')

    if [[ ! "$STATUS_CODE" =~ ^[23]..$ ]]; then
        
        logger -t nginx_smart_monitor "INFO: Status de erro '$STATUS_CODE' detectado. Preparando alerta."

        SERVER_HOSTNAME=$(hostname)
        
        # Sanitização robusta para garantir que o JSON não quebre
        SANITIZED_LOG_LINE=$(echo "$LAST_LOG_LINE" | tr -d '\n\r' | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')

        # Monta a estrutura do JSON
        JSON_PAYLOAD=$(printf '{
          "username": "Nginx Status Alert",
          "content": "🚨 **ALERTA: O SERVIDOR NGINX RETORNOU UM ERRO** 🚨",
          "embeds": [
            {
              "title": "Status HTTP Anormal Detectado",
              "description": "O script de verificação periódica detectou que o Nginx respondeu com um código de erro.",
              "color": 15158332,
              "fields": [
                {
                  "name": "Servidor",
                  "value": "`%s`"
                },
                {
                  "name": "Linha de Log Completa",
                  "value": "```\n%s\n```"
                }
              ]
            }
          ]
        }' "$SERVER_HOSTNAME" "$SANITIZED_LOG_LINE")

        # --- ENVIO ROBUSTO E DEPURAÇÃO ---
        
        # 1. Registra o JSON exato que será enviado para depuração
        logger -t nginx_smart_monitor "DEBUG: Enviando o seguinte payload JSON: $JSON_PAYLOAD"

        # 2. Envia o JSON diretamente para o curl, evitando problemas com variáveis
        RESPONSE=$(echo "$JSON_PAYLOAD" | curl --write-out "\nHTTP_STATUS:%{http_code}" -s -X POST -H "Content-Type: application/json" -d @- "$DISCORD_WEBHOOK_URL")
        
        # 3. Registra a resposta do Discord para depuração
        logger -t nginx_smart_monitor "INFO: Resposta do Discord: $RESPONSE"
        # ------------------------------------
    fi
done