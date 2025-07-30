#!/bin/bash

# ===================================================================================
# Script para AUTOMATIZAR a configuração de um monitoramento para o Nginx
# usando systemd timers, para rodar a cada 5 segundos.
#
# Este script deve ser executado com privilégios de root (ou sudo).
# ===================================================================================

# Garante que o script pare se algum comando falhar
set -e

# --- Definir os caminhos e criar o script de monitoramento ---
SCRIPT_PATH="/usr/local/bin/log_nginx_status.sh"
LOG_FILE="/var/log/nginx_status.log"
SERVICE_FILE="/etc/systemd/system/nginx-log.service"
TIMER_FILE="/etc/systemd/system/nginx-log.timer"

# --- VERIFICAR SE A CONFIGURAÇÃO JÁ EXISTE ---
if [ -f "$SCRIPT_PATH" ] || [ -f "$SERVICE_FILE" ] || [ -f "$TIMER_FILE" ]; then
  echo "INFO: Um ou mais arquivos de configuração já foram encontrados."
  echo "      - Script: $SCRIPT_PATH"
  echo "      - Serviço: $SERVICE_FILE"
  echo "      - Timer: $TIMER_FILE"
  echo "INFO: Presumindo que o serviço já está configurado. Nenhuma ação será tomada."
  # Sai do script com sucesso (código 0), pois não fazer nada é o comportamento esperado.
  exit 0
fi

# --- Se o script chegou até aqui, significa que a configuração não existe ---
echo "INFO: Nenhuma configuração encontrada. Iniciando a instalação do monitoramento..."
echo "----------------------------------------------------"


echo "INFO: Criando o script de monitoramento em $SCRIPT_PATH..."

# Usando cat com HEREDOC para criar o script de verificação
cat > "$SCRIPT_PATH" << EOF
#!/bin/bash
LOG_FILE="$LOG_FILE"
URL="http://127.0.0.1"
TIMESTAMP=\$(date '+%Y-%m-%d %H:%M:%S')
STATUS_CODE=\$(curl -s -o /dev/null -w "%{http_code}" \$URL)
echo "\$TIMESTAMP - Nginx Status: \$STATUS_CODE" >> "\$LOG_FILE"
EOF

# Nota: Os '$' dentro do HEREDOC foram escapados com '\' (ex: \$TIMESTAMP)
# para que não sejam interpretados pelo shell atual, mas sim escritos no arquivo.

# Tornar o script executável
chmod +x "$SCRIPT_PATH"

echo "INFO: Script de monitoramento criado com sucesso."
echo "----------------------------------------------------"

# --- Criar o arquivo de serviço systemd ---
SERVICE_FILE="/etc/systemd/system/nginx-log.service"
echo "INFO: Criando o arquivo de serviço em $SERVICE_FILE..."

cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Log Nginx Status

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
EOF

echo "INFO: Arquivo de serviço criado com sucesso."
echo "----------------------------------------------------"

# --- Passo 3: Criar o arquivo de timer systemd ---
TIMER_FILE="/etc/systemd/system/nginx-log.timer"
echo "INFO: Criando o arquivo de timer em $TIMER_FILE..."

cat > "$TIMER_FILE" << EOF
[Unit]
Description=Run nginx-log.service every 1 minute

[Timer]
OnUnitActiveSec=1m
OnBootSec=1s

[Install]
WantedBy=timers.target
EOF

echo "INFO: Arquivo de timer criado com sucesso."
echo "----------------------------------------------------"

# --- Passo 4: Preparar o arquivo de log ---
echo "INFO: Criando e configurando as permissões para o arquivo de log $LOG_FILE..."
touch "$LOG_FILE"
# Dá permissão de escrita para o dono (root) e para o grupo (root), e leitura para outros
chmod 664 "$LOG_FILE"

# --- Passo 5: Habilitar e iniciar o timer ---
echo "INFO: Recarregando o daemon do systemd, habilitando e iniciando o timer..."

systemctl daemon-reload
# O comando '--now' habilita e inicia o timer de uma só vez
systemctl enable --now nginx-log.timer

echo "----------------------------------------------------"
echo "SUCESSO! O monitoramento foi configurado e já está ativo."
echo ""
echo "Para verificar o status do timer, use:"
echo "sudo systemctl status nginx-log.timer"
echo ""
echo "Para ver os logs em tempo real, use:"
echo "tail -f /var/log/nginx_status.log"