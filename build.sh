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
cmake .
make
make install

echo Removing old RakNet installation if it exists.
sudo rm -rf /usr/local/include/raknet

echo Moving RakNet to the correct directory.
sudo mv Lib/LibStatic/libRakNetLibStatic.a /usr/local/lib
sudo mv include/raknet /usr/local/include/

echo RakNet installed.

