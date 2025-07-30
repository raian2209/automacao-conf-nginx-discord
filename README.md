
git clone https://github.com/raian2209/automacao-conf-nginx-discord.git

cd automacao-conf-nginx-discord

chmod +x *.sh

sudo ./install-nginx.sh

export DISCORD_WEBHOOK_URL = "Sua_credencial_aqui"

sudo -E ./automat-orq.sh



sudo ./install-nginx.sh

sudo -E ./automat-orq.sh
-----------------
sudo systemctl status nginx

sudo systemctl stop nginx

sudo systemctl start nginx

sudo systemctl reload nginx


sudo systemctl status nginx-log.timer

sudo systemctl status nginx-log-monitor.service

---------------------


sudo tail -f /var/log/nginx_status.log