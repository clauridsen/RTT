#!/bin/bash

# Dependencies installation:


sudo apt-get install -y build-essential gdb g++ zip cmake
sudo apt-get install -y libsdl2-dev
sudo apt install -y libsdl2-image-dev
sudo apt install -y libsdl2-ttf-dev
sudo apt-get install -y libglew-dev
sudo apt-get install libbullet-dev -y

# RakNet installation:
git clone https://github.com/facebookarchive/RakNet.git /home/pi/RakNet
cd /home/pi/RakNet
sudo reboot
