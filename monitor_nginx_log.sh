#!/bin/bash

# Este script monitora o log de status do Nginx e envia um alerta ao Discord
# apenas quando um código de status de erro (diferente de 2xx ou 3xx) é detectado.
# VERSÃO CORRIGIDA (V2)

LOG_FILE="/var/log/nginx_status.log"

# Verifica se a variável de ambiente com a URL do webhook do Discord existe.
if [ -z "$DISCORD_WEBHOOK_URL" ]; then
    echo "ERRO: A variável de ambiente DISCORD_WEBHOOK_URL não está configurada." >&2
    exit 1
fi

echo "INFO: Monitoramento do arquivo '$LOG_FILE' iniciado. Aguardando por status de erro..."

# Loop mais robusto: 'inotifywait' agora apenas controla o fluxo do loop.
# Ele pausa o script aqui até que o arquivo seja modificado.
while inotifywait --quiet -e modify "$LOG_FILE"; do
    
    # Após a modificação, lê a última linha do arquivo.
    # Esta é a forma correta, garantindo que a variável não seja contaminada.
    LAST_LOG_LINE=$(tail -n 1 "$LOG_FILE")

    # Extrai a última palavra da linha, que é o código de status HTTP.
    STATUS_CODE=$(echo "$LAST_LOG_LINE" | awk '{print $NF}')

    # Condição: Dispara o alerta se o código de status NÃO começar com 2 ou 3.
    # Isso cobre erros 4xx, 5xx, e o código 000 do curl (falha de conexão).
    if [[ ! "$STATUS_CODE" =~ ^[23]..$ ]]; then
        
        echo "INFO: Status de erro '$STATUS_CODE' detectado. Enviando alerta para o Discord..."

        # Coleta informações adicionais para o alerta.
        SERVER_HOSTNAME=$(hostname)
        # Prepara a linha de log para ser enviada de forma segura em JSON.
        SANITIZED_LOG_LINE=$(echo "$LAST_LOG_LINE" | sed 's/"/\\"/g')

        # Monta a mensagem para o Discord usando o formato "Embed".
        JSON_PAYLOAD=$(printf '{
          "username": "Nginx Status Alert",
          "content": "🚨 **ALERTA: O SERVIDOR NGINX RETORNOU UM ERRO** 🚨",
          "embeds": [
            {
              "title": "Status HTTP Anormal Detectado",
              "description": "O script de verificação periódica detectou que o Nginx respondeu com um código de erro, indicando um problema.",
              "color": 15747399,
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

        # Envia a notificação para o Discord.
        curl --silent --show-error -X POST -H "Content-Type: application/json" -d "$JSON_PAYLOAD" "$DISCORD_WEBHOOK_URL"
    fi
done