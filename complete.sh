#!/bin/bash

# Ensure script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Update and install dependencies
echo "Installing necessary packages..."
sudo apt-get update
sudo apt-get install -y build-essential gdb g++ zip cmake libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libglew-dev

# Clone RakNet and set the required configuration
echo "Cloning RakNet..."
cd ~
if [ ! -d "RakNet" ]; then
  git clone https://github.com/larku/RakNet
fi

# Modify RakNetDefinesOverrides.h for compatibility
echo "Configuring RakNet for RTTClient..."
cd ~/RakNet/Source
if grep -q "#define USE_SLIDING_WINDOW_CONGESTION_CONTROL 0" RakNetDefinesOverrides.h; then
  echo "RakNetDefinesOverrides.h already configured."
else
  echo "#define USE_SLIDING_WINDOW_CONGESTION_CONTROL 0" >> RakNetDefinesOverrides.h
  echo "RakNetDefinesOverrides.h updated."
fi

# Compile RakNet
echo "Building RakNet..."
cmake .
cmake --build .

# Clone the RTTClient project
echo "Cloning RTTClient..."
mkdir -p ~/projects
cd ~/projects
if [ ! -d "rttclient" ]; then
  git clone https://github.com/clauridsen/RTTClient.git # Replace with the actual repository link
fi

# Build RTTClient
echo "Building RTTClient..."
cd rttclient
cmake .
cmake --build .

# Move the necessary files to ~/RTTClient
echo "Setting up RTTClient folder..."
mkdir -p ~/RTTClient
cp src/RTTClient ~/RTTClient/
cp RTTClient.ini ~/RTTClient/
cp font.ttf ~/RTTClient/

# Create the start.sh script
echo "Creating start.sh..."
cat << 'EOF' > ~/RTTClient/start.sh
#!/bin/bash
cd /home/pi/RTTClient
./RTTClient
EOF

# Make start.sh and RTTClient executable
chmod +x ~/RTTClient/start.sh
chmod +x ~/RTTClient/RTTClient

# Setup autostart for RTTClient
echo "Configuring autostart..."
mkdir -p ~/.config/autostart
cat << 'EOF' > ~/.config/autostart/rtt.desktop
[Desktop Entry]
Type=Application
Name=RTTClient
Exec=/home/pi/RTTClient/start.sh
EOF

# Inform the user that the setup is complete
echo "RTTClient setup complete. It will now start automatically on boot."
