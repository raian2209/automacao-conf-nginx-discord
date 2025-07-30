
git clone https://github.com/raian2209/automacao-conf-nginx-discord.git
cd automacao-conf-nginx-discord
chmod +x *.sh
sudo -E ./automat-orq.sh
export DISCORD_WEBHOOK_URL = "Sua_credencial_aqui"
sudo ./install-nginx.sh
sudo ./automat-orq.sh
