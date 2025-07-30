
# 🤖 Automação de Servidor Nginx com Alertas Inteligentes no Discord

Este projeto automatiza a instalação, configuração e monitoramento de um servidor web Nginx em sistemas Ubuntu.

O sistema é dividido em duas partes principais:

1.  **Geração de Logs**: Um serviço agendado (`systemd timer`) verifica o status do Nginx a cada minuto e registra o resultado em um arquivo de log.
2.  **Monitoramento e Alertas**: Um segundo serviço monitora este arquivo de log em tempo real e envia um alerta detalhado para um canal do Discord **apenas se** um código de status de erro (como 5xx, 4xx ou falha de conexão) for detectado.

## ✨ Funcionalidades

  * **Instalação Automatizada**: Instalação e configuração do Nginx e de todas as dependências (`inotify-tools`) com um único comando.
  * **Logging Periódico**: Utiliza `systemd timers` para registrar o status do servidor web em `/var/log/nginx_status.log` a cada minuto.
  * **Alertas Condicionais**: Notificações são enviadas ao Discord apenas quando um status de erro é logado, evitando alertas desnecessários.
  * **Scripts Idempotentes**: Os scripts de configuração podem ser executados múltiplas vezes sem causar problemas. Se uma configuração já existir, nada será alterado.
  * **Serviços Resilientes**: O script de monitoramento é configurado como um serviço do `systemd`, garantindo que seja reiniciado em caso de falha.

## ⚙️ Pré-requisitos

  * Um servidor com sistema operacional **Ubuntu**.
  * Acesso como usuário **root** ou com privilégios `sudo`.
  * Uma **URL de Webhook** de um canal do Discord.

## 🚀 Passo a Passo para Instalação

Siga estes passos na ordem correta para configurar o ambiente completo.

**Passo 1: Clonar o Repositório**

```bash
git clone https://github.com/raian2209/automacao-conf-nginx-discord.git
```

**Passo 2: Entrar no Diretório**

```bash
cd automacao-conf-nginx-discord
```

**Passo 3: Dar Permissão de Execução**

```bash
chmod +x *.sh
```

**Passo 4: Exportar a URL do Webhook**
Este é um passo crucial. A URL é passada para os scripts como uma variável de ambiente. Execute este comando na mesma sessão de terminal em que você executará os scripts.

```bash
export DISCORD_WEBHOOK_URL="SUA_URL_DE_WEBHOOK_AQUI"
```

**Passo 5: Instalar o Nginx e o Gerador de Logs**
Este comando prepara o servidor com o Nginx e configura o `systemd timer` que irá gerar o arquivo de log a cada minuto.

```bash
sudo ./install-nginx.sh
```

**Passo 6: Configurar o Monitor de Alertas**
Este comando configura o serviço que assiste ao log e envia os alertas. É **essencial** usar a flag `-E` para que a variável `DISCORD_WEBHOOK_URL` (do Passo 4) seja preservada e "enxergada" pelo script.

```bash
sudo -E ./automat-orq.sh
```

Pronto\! Seu ambiente está configurado e monitorado.

## ✅ Verificação e Comandos Úteis

Para verificar se os serviços estão rodando corretamente, use os seguintes comandos:

  * **Verificar o status do Nginx:**

    ```bash
    sudo systemctl status nginx
    ```

  * **Verificar o status do Timer que gera os logs:**

    ```bash
    sudo systemctl status nginx-log.timer
    ```

  * **Verificar o status do Serviço que envia os alertas:**

    ```bash
    sudo systemctl status nginx-log-monitor.service
    ```

  * **Ver os logs de status do Nginx em tempo real:**

    ```bash
    sudo tail -f /var/log/nginx_status.log
    ```

## 📜 Descrição dos Scripts Principais

  * `install-nginx.sh`: Script principal que instala o Nginx e as dependências necessárias. Ao final, ele chama o `Config-nginx.sh` para iniciar a configuração do logging.
  * `Config-nginx.sh`: Cria o script `/usr/local/bin/log_nginx_status.sh` e o serviço `systemd.timer` para registrar o status do Nginx periodicamente.
  * `automat-orq.sh`: O orquestrador principal para a parte de alertas. Ele cria o serviço do monitor e o arquivo de ambiente com a URL do Discord.
  * `monitor_nginx_log.sh`: O "agente" de monitoramento. Ele roda continuamente, assiste ao arquivo de log e envia um alerta para o Discord se detectar um código de status de erro.

## ⚖️ Licença

Este projeto é distribuído sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.


