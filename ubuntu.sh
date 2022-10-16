#!/bin/bash
ORIGIN_DIR=echo "$PWD"
if [ -d Openslides]; then
echo "Directory \"Openslides\" ist already taken up. please remove the directory through 'rm -rf Openslides'"
else
mkdir OpenSlides
cd Openslides
fi
sudo apt install docker.io -y && sudo apt install docker-compose -y && sudo apt install git -y
wget https://github.com/OpenSlides/openslides-manage-service/releases/download/latest/openslides
chmod +x openslides
./openslides setup .
docker-compose pull
docker-compose up -d
./openslides initial-data
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
cd ..
if [-f /etc/caddy/Caddyfile]; then
rm /etc/caddy/Caddyfile
cp Caddyfile /etc/caddy/Caddyfile
else
cp Caddyfile /etc/caddy/Caddyfile
fi
cd /etc/caddy/
caddy start
echo "All up and running. Call https://localhost"