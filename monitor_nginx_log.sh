#!/bin/bash

# Este script usa inotifywait para monitorar o log de erros do Nginx
# e envia um alerta para o Discord quando o arquivo é modificado.

apt-get install inotify-tools -y
# --- CONFIGURAÇÃO ---
# Arquivo de log a ser monitorado. O .log é ideal para alertas.
LOG_FILE_TO_WATCH="/var/log/nginx_status.log"

# A URL do Webhook é passada pelo ambiente (configurado no systemd)
if [ -z "$DISCORD_WEBHOOK_URL" ]; then
    logger -t nginx_log_monitor "ERRO: A variável de ambiente DISCORD_WEBHOOK_URL não está configurada."
    exit 1
fi
# --- FIM DA CONFIGURAÇÃO ---

echo "INFO: Iniciando o monitoramento do arquivo: $LOG_FILE_TO_WATCH" | logger -t nginx_log_monitor

# Loop infinito para garantir que o monitoramento continue mesmo após um evento.
while true
do
    # O comando inotifywait fica bloqueado aqui até que o evento 'modify' ocorra.
    # -e modify: Escuta apenas por eventos de modificação (escrita no arquivo).
    # --quiet: Suprime a saída padrão do inotifywait.
    inotifywait --quiet -e modify "$LOG_FILE_TO_WATCH"

    # Quando o comando acima é desbloqueado, significa que o arquivo mudou.
    # Pegamos a última linha adicionada ao log para incluir no alerta.
    LAST_LOG_LINE=$(tail -n 1 "$LOG_FILE_TO_WATCH")

    # Formata a mensagem de alerta para o Discord
    MESSAGE="🔥 **ALERTA NO LOG DO NGINX** 🔥\n\nDetectada nova entrada no arquivo \`error.log\`.\n\n\`\`\`\n$LAST_LOG_LINE\n\`\`\`\n- **Servidor:** \`$(hostname)\`"

    # Envia a notificação para o Discord
    curl -X POST -H "Content-Type: application/json" -d "{\"content\": \"$MESSAGE\"}" "$DISCORD_WEBHOOK_URL"
done