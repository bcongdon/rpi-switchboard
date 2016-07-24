# !/bin/bash

# Install packages
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install --upgrade python-pip
sudo apt-get install -y npm git node python-dev
sudo npm install -g n
sudo n lts
sudo npm install -g wunderschedule forever

# Fetch repos
git clone https://github.com/bcongdon/Scripts ~/Scripts

# Create startup script
cat > ~/startup.sh <<-EOF
forever start -c wunderschedule .
forever start Scripts/pyuiuc-notify/scheduler.js

EOF
chmod +x ~/startup.sh

# Install pip requirements
sudo pip install -r ~/Scripts/mfp/requirements.txt
sudo pip install -r ~/Scripts/youtube/requirements.txt

# Setup cron jobs
crontab -l > mycron
echo "@reboot . ~/startup.sh" >> mycron
echo "59 23 * * * python ~/Scripts/mfp/mfp.py" >> mycron
echo "59 23 * * * python ~/Scripts/youtube/history_scraper.py" >> mycron
crontab mycron
rm mycron

# Prompt for json secrets
secrets_files=(
    ~/Scripts/youtube/client_secret.json,
    ~/Scripts/youtube/youtube_client_secrets.json,
    ~/Scripts/youtube/history_scraper.py-oauth2.json
    ~/Scripts/mfp/client_secret.json,
    ~/Scripts/pyuiuc-notify/settings.json
    )

for s_file in "${secrets_files[@]}"
do
    echo "Input secrets for ${s_file}"
    sleep 2s
    ${VISUAL:-${EDITOR:-vi}} $s_file
done

# Run startup script for initial run
. ~/startup.sh
