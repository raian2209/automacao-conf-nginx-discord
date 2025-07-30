#!/bin/bash

bash ./script-automas-criarsys.sh
bash ./automat-erro.sh




echo "INFO: Arquivo de serviço criado com sucesso."
echo "----------------------------------------------------"
echo "Recarrega o systemd para reconhecer o novo serviço"
sudo systemctl daemon-reload


echo "Habilita o serviço para iniciar no boot e o inicia imediatamente"
sudo systemctl enable --now nginx-log-monitor.service


echo "INFO: Serviço de monitoramento do Nginx configurado e iniciado com sucesso."
echo "----------------------------------------------------"
echo "Para verificar o status do serviço, use o comando:"
sudo systemctl status nginx-log-monitor.service