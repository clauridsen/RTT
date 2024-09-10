#!/bin/bash

# Ensure script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Function to remove directory if it exists
remove_dir_if_exists() {
  if [ -d "$1" ]; then
    echo "Removing existing directory $1..."
    rm -rf "$1"
    echo "Directory $1 removed."
  fi
}

# Update and install dependencies
echo "Installing necessary packages..."
sudo apt-get update
sudo apt-get install -y build-essential gdb g++ zip cmake libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libglew-dev

# Remove existing RakNet directory if it exists
remove_dir_if_exists "/home/pi/RakNet"

# Clone RakNet and set the required configuration
echo "Cloning RakNet..."
cd /home/pi
git clone https://github.com/larku/RakNet

# Modify RakNetDefinesOverrides.h for compatibility
echo "Configuring RakNet for RTTClient..."
cd /home/pi/RakNet/Source
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

# Remove existing RTTClient directory if it exists
remove_dir_if_exists "/home/pi/projects/RTTClient"

# Clone the RTTClient project
echo "Cloning RTTClient..."
mkdir -p /home/pi/projects
cd /home/pi/projects
git clone https://github.com/clauridsen/RTTClient.git # Replace with the actual repository link

# Verify RTTClient directory exists
if [ ! -d "/home/pi/projects/RTTClient" ]; then
  echo "Error: RTTClient directory was not created."
  exit 1
fi

# Update CMakeLists.txt to include RakNet paths
echo "Updating CMakeLists.txt..."
cat << 'EOF' > /home/pi/projects/RTTClient/CMakeLists.txt
cmake_minimum_required(VERSION 3.18)
cmake_policy(SET CMP0072 NEW)

project(RTTClient)

# Angiv stien til RakNet inkluderingsfiler og bibliotek
set(RAKNET_INCLUDE_DIR "/home/pi/RakNet/Source")
set(RAKNET_LIBRARY "/home/pi/RakNet/Lib/libRakNetLibStatic.a")

# Inkluder RakNet headers
include_directories(${RAKNET_INCLUDE_DIR})

# Tilføj eksekverbar fil
add_executable(RTTClient src/main.cpp)

# Link RakNet biblioteket
target_link_libraries(RTTClient ${RAKNET_LIBRARY})
EOF

# Build RTTClient
echo "Building RTTClient..."
cd /home/pi/projects/RTTClient
cmake .
cmake --build .

# Remove existing RTTClient setup directory if it exists
remove_dir_if_exists "/home/pi/RTTClient"

# Move the necessary files to /home/pi/RTTClient
echo "Setting up RTTClient folder..."
mkdir -p /home/pi/RTTClient
cp /home/pi/projects/RTTClient/src/RTTClient /home/pi/RTTClient/
cp /home/pi/projects/RTTClient/RTTClient.ini /home/pi/RTTClient/
cp /home/pi/projects/RTTClient/font.ttf /home/pi/RTTClient/

# Create the start.sh script
echo "Creating start.sh..."
cat << 'EOF' > /home/pi/RTTClient/start.sh
#!/bin/bash
cd /home/pi/RTTClient
./RTTClient
EOF

# Make start.sh and RTTClient executable
chmod +x /home/pi/RTTClient/start.sh
chmod +x /home/pi/RTTClient/RTTClient

# Setup autostart for RTTClient
echo "Configuring autostart..."
mkdir -p /home/pi/.config/autostart
cat << 'EOF' > /home/pi/.config/autostart/rtt.desktop
[Desktop Entry]
Type=Application
Name=RTTClient
Exec=/home/pi/RTTClient/start.sh
EOF

# Inform the user that the setup is complete
echo "RTTClient setup complete. It will now start automatically on boot."
