#!/bin/bash
echo ###### UPDATING ######
sudo apt update && sudo apt upgrade -y
echo ###### SELECTING DIRECTORY ######
ORIGIN_DIR=echo "$PWD"
#echo "Please enter a directory name for OpenSlides to be installed: "
#read DIR_NAME
echo ###### GATHERING DOMAIN INFORMATION ######
read -r -p "Do you have a FQDN (eg. example.com)? [Y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        read -p "Please provide this Domain: " FQDN
        ;;
    *)
        FQDN=:80
        ;;
esac
echo ###### SETTING UP DIRECTORY ######
#if [ -d DIR_NAME];
#then
#    echo "Directory \"$DIR_NAME\" ist already taken up. please remove the directory through 'rm -rf $DIR_NAME' or rename it"
#else
#    mkdir $DIR_NAME
#    cd $DIR_NAME
#fi
mdkir os4
cd os4
echo ###### INSTALLING NECESSARY DEPENDENCIES ######
sudo apt install docker.io -y && sudo apt install docker-compose -y && sudo apt install git -y
echo ###### GETTING OPENSLIDES MANAGE SERVIVE ######
wget https://github.com/OpenSlides/openslides-manage-service/releases/download/latest/openslides
chmod +x openslides
./openslides setup .
docker-compose pull
docker-compose up -d
./openslides initial-data
echo ###### OPENSLIDES UP AND RUNNING ######
echo ###### INSTALLING CADDY ######
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
cd ..
echo ###### SETTING UP CADDY
echo -en "$FQDN { \n     reverse_proxy https://localhost:8000 { \n               transport http {\n                     tls_insecure_skip_verify\n               }\n     }\n}" > Caddyfile
if [-f /etc/caddy/Caddyfile];
then
    rm /etc/caddy/Caddyfile
    cp Caddyfile /etc/caddy/Caddyfile
else
    cp Caddyfile /etc/caddy/Caddyfile
fi
cd /etc/caddy/
caddy start
cd ORIGIN_DIR
echo "All up and running. Call https://localhost"