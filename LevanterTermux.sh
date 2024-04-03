#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

read -p "Do you have a SESSION_ID scanned today? (y|n): " IS_SESSION_ID
if [[ "$IS_SESSION_ID" == "y" ]]; then
    read -p "Enter Your SESSION_ID: " SESSION_ID
elif [[ "$IS_SESSION_ID" == "n" ]]; then
    read -p "Do you want to continue without SESSION_ID? You can scan QR from this terminal on starting. (y|n): " IS_CONT
    [ "$IS_CONT" == "y" ] || exit 0
else
    exit 0
fi

read -p "Enter a name for BOT (e.g., levanter): " BOT_NAME
BOT_NAME=${BOT_NAME:-levanter}

echo "Updating system packages..."
apt update -y

for pkg in git ffmpeg curl; do
    if ! [ -x "$(command -v $pkg)" ]; then
        echo "Installing $pkg..."
        apt -y install $pkg
    fi
done

if ! [ -x "$(command -v node)" ] || [[ "$(node -v | cut -c 2-)" -lt 16 ]]; then
    echo "Installing Node.js..."
    apt-get purge nodejs
    rm -rf /etc/apt/sources.list.d/nodesource.list
    rm -rf /etc/apt/keyrings/nodesource.gpg
    apt-get update
    apt-get install -y ca-certificates curl gnupg
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
    apt-get update
    apt-get install nodejs -y
fi

if ! [ -x "$(command -v yarn)" ]; then
    echo "Installing Yarn..."
    npm install -g yarn
fi

if ! [ -x "$(command -v pm2)" ]; then
    echo "Installing PM2..."
    yarn global add pm2
fi

echo "Installing Levanter..."
git clone https://github.com/lyfe00011/whatsapp-bot-md "$BOT_NAME"
cd "$BOT_NAME" || exit 1
yarn install --network-concurrency 1

echo "Creating config.env file..."
cat >config.env <<EOL
PREFIX=.
STICKER_PACKNAME=qih47
ALIVE_MESSAGE=HAI, SAYA USERBOT ASSSISTANT ANDA SIAP MELAYANI
APPROVE=reject | approve | all
ALWAYS_ONLINE=false
RMBG_KEY=null
LANGUAG=en
WARN_LIMIT=3
FORCE_LOGOUT=false
BRAINSHOP=159501,6pq8dPiYt7PdqHz3
MAX_UPLOAD=60
REJECT_CALL=false
SUDO=989876543210
TZ=Asia/Jakarta
VPS=true
AUTO_STATUS_VIEW=false
SEND_READ=false
AJOIN=true
GPT=free
MENTION=MENTION: { "contextInfo": { "forwardingScore": 5, "isForwarded": true }, "linkPreview": { "head": "Test", "body": "HAHA", "mediaType": 2, "thumbnail": "https://i1.sndcdn.com/avatars-000600452151-38sfei-t500x500.jpg", "sourceUrl": "https://www.github.com/lyfe00011/whatsapp-bot-md" } , "waveform": [ 20,5,0,80,80,30,20,50 ] }
PERS=null
REJECT_CALL=false
EOL
[ "$SESSION_ID" != "1" ] && echo "SESSION_ID=$SESSION_ID" >>config.env

echo "Starting the bot..."
pm2 start index.js --name "$BOT_NAME" --attach --time