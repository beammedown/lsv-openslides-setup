#!/bin/bash
sudo yum update && sudo yum upgrade -y
ORIGIN_DIR=echo "$PWD"
echo "Please enter a directory name for OpenSlides to be installed: "
read DIR_NAME

read -r -p "Do you have a FQDN (eg. example.com)? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        read -p "Please provide this Domain" FQDN
        ;;
    *)
        FQDN=:80
        ;;
esac

if [ -d DIR_NAME]; then
echo "Directory \"$DIR_NAME\" ist already taken up. please remove the directory through 'rm -rf $DIR_NAME' or rename it"
else
mkdir $DIR_NAME
cd $DIR_NAME
fi
sudo yum install docker.io -y && sudo yum install docker-compose -y && sudo yum install git -y
wget https://github.com/OpenSlides/openslides-manage-service/releases/download/latest/openslides
chmod +x openslides
./openslides setup .
docker-compose pull
docker-compose up -d
./openslides initial-data
dnf install 'dnf-command(copr)'
dnf copr enable @caddy/caddy
dnf install caddy
cd ..
echo -en '$FQDN { \n     reverse_proxy https://localhost:8000 { \n               transport http {\n                     tls_insecure_skip_verify\n               }\n     }\n}' > Caddyfile
if [-f /etc/caddy/Caddyfile]; then
rm /etc/caddy/Caddyfile
cp Caddyfile /etc/caddy/Caddyfile
else
cp Caddyfile /etc/caddy/Caddyfile
fi
cd /etc/caddy/
caddy start
cd ORIGIN_DIR
echo "All up and running. Call https://localhost"