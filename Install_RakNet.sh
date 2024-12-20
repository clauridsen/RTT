#!/bin/bash

# Opdater systemet og installer nødvendige pakker
sudo apt-get update
sudo apt-get upgrade --yes

# Installer build-værktøjer og nødvendige biblioteker
sudo apt-get install -y build-essential gdb g++ zip

# Check if git is installed, if not, install it
if ! command -v git &> /dev/null
then
    echo "git could not be found, installing git."
    sudo apt-get install -y git
fi

# Check if cmake is installed, if not, install it
if ! command -v cmake &> /dev/null
then
    echo "cmake could not be found, installing cmake."
    sudo apt-get install -y cmake
fi

sudo apt-get install -y libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev
sudo apt-get install -y libglew-dev libbullet-dev

# RakNet installation
echo "Cloning RakNet repository..."
if [ ! -d "RakNet" ]; then
    git clone https://github.com/clauridsen/RakNet.git
else
    echo "RakNet repository already exists."
fi
cd RakNet

# Opret en build-mappe og byg RakNet med CMake
echo "Building RakNet..."
mkdir -p build && cd build
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
