#!/bin/bash

POSITIONAL_ARGS=()

if [[ $# -eq 0 ]]
    then
        echo "lsvops ist ein Tool, welches OpenSlides automatisch installiert und hinter eine Domain verpackt.

Nutzung:
  ./ubuntu.sh [command]

Verfügbare Commands:
  -d   --directory             Lege das Installationsverzeichnis fest
  -url --domain                Lege die Domain fest
  -s   --default               Benutzt Standardwerte aus Dokumentation
  -v   --version               Zeigt die Version des Skripts


Flags:
  -h, --help   Hilfe für das Skript

Use 'openslides [command] --help' for more information about a command."
        exit 0
fi

echo "#############################################"
echo "########## OpenSlides 4 Installer ###########"
echo "#############################################"

while [[ $# -gt 0 ]]; do
    case $1 in
    -d|--directory)
        DIRECTORY="$2"
        shift
        shift
        ;;
    -url|--domain)
        FQDN="$2"
        shift
        shift
        ;;
    -s|--default)
        DEFAULT=true
        shift
        ;;
    -*|--*)
        echo "Unknown option $1"
        exit 1
        ;;
    *)
        POSITIONAL_ARGS+=("$1")
        shift
        ;;
    esac
done

if [[ $DEFAULT ]]
then
    echo "Set default"
    DIRECTORY="os4"
    FQDN=":80"
else
    if [[ -z $DIRECTORY ]]
    then
            echo "Kein Installationsverzeichnis angegeben. Bitte gib ein Installationsverzeichnis mit der -d oder --directory Option an. Alternativ nutze --default"
            exit 0
    elif [[ -z $FQDN ]]
    then
        echo "Keine Domain angegeben. Bitte gib eine Domain mit der -url oder --domain Option an. Alternativ nutze --default"
        exit 0
    fi
fi

echo "Prüfe auf Updates..."
echo ###### UPDATING ######
sudo apt update && sudo apt upgrade -y

echo ###### SELECTING DIRECTORY ######
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ###### SETTING UP DIRECTORY ######
if [ -d "$DIRECTORY" ]
then
    echo "Directory '${DIRECTORY}' ist already taken up. please remove the directory through 'rm -rf ${DIRECTORY}' or rename it"
    exit
else
    mkdir "$DIRECTORY"
    cd "$DIRECTORY"
fi

echo ###### INSTALLING NECESSARY DEPENDENCIES ######
if [ -x "$(command -v docker)" ]; then
    echo "Docker ist bereits installiert. Fahre fort..."
else
    echo "Docker wird installiert..."
    sudo apt-get update
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

sudo apt install git -y

echo ###### GETTING OPENSLIDES MANAGE SERVIVE ######
wget https://github.com/OpenSlides/openslides-manage-service/releases/download/latest/openslides
chmod +x openslides
./openslides setup .
docker compose pull
docker compose up --detach
./openslides check-server
./openslides initial-data
echo ###### OPENSLIDES UP AND RUNNING ######
echo ###### INSTALLING CADDY ######
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
cd ..
echo ###### SETTING UP CADDY ########
echo -en "$FQDN { \n    reverse_proxy https://localhost:8000 { \n        transport http {\n            tls_insecure_skip_verify\n        }\n    }\n}" > Caddyfile
if [ -f /etc/caddy/Caddyfile ]; then rm /etc/caddy/Caddyfile && cp Caddyfile /etc/caddy/Caddyfile; else cp Caddyfile /etc/caddy/Caddyfile; fi
cd /etc/caddy/
caddy start
cd "${__dir}"
echo "All up and running. Call https://$FQDN to access OpenSlides."
echo "Wenn du OpenSlides herunterfahren möchtest, kannst du einfach in ${__dir}/os4/ den Befehl 'docker compose down' eingeben."

echo "#############################################"
echo "########## IMPORTANT INFORMATIONS ###########"
echo "#############################################"
echo "STANDARD USERNAME: superadmin"
echo "STANDARD PASSWORD: superadmin"
echo "BITTE ÄNDERE DAS PASSWORT SOFORT NACH DER ERSTEN ANMELDUNG!"
echo "#############################################"

exit 0