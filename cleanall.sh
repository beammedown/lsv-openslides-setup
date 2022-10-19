#!/bin/bash
docker kill $(docker ps -q)
docker container prune
docker volume prune
docker rmi $(docker images -q) -f
cd
rm -rf lsv-openslides-setup
cd /etc/caddy
caddy stop
cd
sudo rm /etc/apt/sources.list.d/caddy-stable.list
sudo apt remove caddy
echo "All done. OpenSlides, the installation script and Caddy have been removed."