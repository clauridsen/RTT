# RakNet installation:
sudo git clone https://github.com/clauridsen/RakNet.git /pi/RakNet
cd /pi/RakNet

sudo cmake .
sudo make
sudo make install

echo Removing old RakNet installation if it exists.
sudo rm -rf /usr/local/include/raknet

echo Moving RakNet to the correct directory.
sudo mv Lib/LibStatic/libRakNetLibStatic.a /usr/local/lib
sudo mv include/raknet /usr/local/include/

echo RakNet installed.
