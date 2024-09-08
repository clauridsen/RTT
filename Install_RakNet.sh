#!/bin/bash

# Opdater systemet og installer nødvendige pakker
sudo apt-get update
sudo apt-get upgrade --yes

# Installer build-værktøjer og nødvendige biblioteker
sudo apt-get install -y build-essential gdb g++ zip cmake
sudo apt-get install -y libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev
sudo apt-get install -y libglew-dev libbullet-dev git

# RakNet installation
echo "Cloning RakNet repository..."
git clone https://github.com/clauridsen/RakNet.git
cd RakNet

# Opret en build-mappe og byg RakNet med CMake
echo "Building RakNet..."
mkdir build && cd build
cmake ..
make

# Installer RakNet
echo "Installing RakNet..."
sudo make install

# Flyt bibliotek og inkluderingsfiler til de korrekte stier
echo "Removing old RakNet installation if it exists."
sudo rm -rf /usr/local/include/raknet

echo "Moving RakNet to the correct directory."
sudo mv ../Lib/LibStatic/libRakNetLibStatic.a /usr/local/lib
sudo mv ../include/raknet /usr/local/include/

echo "RakNet installed successfully."
