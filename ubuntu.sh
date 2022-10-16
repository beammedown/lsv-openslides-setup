#!/bin/bash
if [ -d Openslides]; then
mkdir OpenSlides
cd Openslides
else
echo "Directory \"Openslides\" ist already taken up. please remove the directory through 'rm -rf Openslides'"

#sudo apt install docker.io -y && sudo apt install docker-compose -y && sudo apt install git -y
#wget https://github.com/OpenSlides/openslides-manage-service/releases/download/latest/openslides
#chmod +x openslides
