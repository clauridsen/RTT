#!/bin/bash

# Dependencies installation:

sudo apt-get update

sudo apt-get upgrade --yes



sudo apt-get install -y build-essential gdb g++ zip cmake
sudo apt-get install -y libsdl2-dev
sudo apt install -y libsdl2-image-dev
sudo apt install -y libsdl2-ttf-dev
sudo apt-get install -y libglew-dev
sudo apt-get install libbullet-dev -y
sudo apt install git --yes

# RakNet installation:
git clone https://github.com/clauridsen/RakNet.git /home/pi/RakNet


git clone https://github.com/johndcollins/RTTClient.git /home/pi/RTTClient


sudo reboot
