#!/bin/bash

# Version 2.4

# Ensure script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Log file
LOG_FILE="/home/pi/install_log.txt"

# Function to remove directory if it exists
remove_dir_if_exists() {
  if [ -d "$1" ]; then
    echo "Removing existing directory $1..." | tee -a "$LOG_FILE"
    rm -rf "$1"
    echo "Directory $1 removed." | tee -a "$LOG_FILE"
  fi
}

# Update and install dependencies
echo "Installing necessary packages..." | tee -a "$LOG_FILE"
sudo apt-get update | tee -a "$LOG_FILE"
sudo apt-get install -y build-essential gdb g++ zip cmake libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libglew-dev | tee -a "$LOG_FILE"

# Remove existing RakNet directory if it exists
remove_dir_if_exists "/home/pi/RakNet"

# Clone and build RakNet
echo "Cloning and building RakNet..." | tee -a "$LOG_FILE"
cd /home/pi
git clone https://github.com/chrisi/RakNet.git | tee -a "$LOG_FILE"
cd RakNet
mkdir build
cd build
cmake -DDISABLEDEPENDENCIES=TRUE ../ | tee -a "$LOG_FILE"
make | tee -a "$LOG_FILE"

# Remove existing RTTClient directory if it exists
remove_dir_if_exists "/home/pi/projects/RTTClient"

# Clone the RTTClient project
echo "Cloning RTTClient..." | tee -a "$LOG_FILE"
mkdir -p /home/pi/projects
cd /home/pi/projects
git clone https://github.com/clauridsen/RTTClient.git | tee -a "$LOG_FILE" # Replace with the actual repository link

# Verify RTTClient directory exists
if [ ! -d "/home/pi/projects/RTTClient" ]; then
  echo "Error: RTTClient directory was not created." | tee -a "$LOG_FILE"
  exit 1
fi

# Update CMakeLists.txt to include RakNet paths
echo "Updating CMakeLists.txt..." | tee -a "$LOG_FILE"
cat << 'EOF' > /home/pi/projects/RTTClient/CMakeLists.txt
cmake_minimum_required(VERSION 3.18)
cmake_policy(SET CMP0072 NEW)

project(RTTClient)

# Angiv stien til RakNet inkluderingsfiler og bibliotek
set(RAKNET_INCLUDE_DIR "/home/pi/RakNet/Source")
set(RAKNET_LIBRARY "/home/pi/RakNet/build/libRakNetLibStatic.a")

# Inkluder RakNet headers
include_directories(${RAKNET_INCLUDE_DIR})

# Tilføj eksekverbar fil
add_executable(RTTClient src/main.cpp)

# Link RakNet biblioteket og andre nødvendige biblioteker
target_link_libraries(RTTClient ${RAKNET_LIBRARY} SDL2 SDL2_image SDL2_ttf GLEW GL pthread)
EOF

# Build RTTClient using CMake
echo "Building RTTClient with CMake..." | tee -a "$LOG_FILE"
cd /home/pi/projects/RTTClient
cmake . | tee -a "$LOG_FILE"
cmake --build . | tee -a "$LOG_FILE" 2>&1

# If CMake build fails, try manual build
if [ ! -f "src/RTTClient" ]; then
  echo "CMake build failed. Trying manual build..." | tee -a "$LOG_FILE"
  cd /home/pi/projects/RTTClient/src
  g++ -I/home/pi/RakNet/Source -o RTTClient main.cpp /home/pi/RakNet/build/libRakNetLibStatic.a -lSDL2 -lSDL2_image -lSDL2_ttf -lGLEW -lGL -lpthread | tee -a "$LOG_FILE" 2>&1
  if [ ! -f "RTTClient" ]; then
    echo "Error: RTTClient was not built." | tee -a "$LOG_FILE"
    exit 1
  fi
fi

# Remove existing RTTClient setup directory if it exists
remove_dir_if_exists "/home/pi/RTTClient"

# Move the necessary files to /home/pi/RTTClient
echo "Setting up RTTClient folder..." | tee -a "$LOG_FILE"
mkdir -p /home/pi/RTTClient
cp /home/pi/projects/RTTClient/src/RTTClient /home/pi/RTTClient/
cp /home/pi/projects/RTTClient/RTTClient.ini /home/pi/RTTClient/
cp /home/pi/projects/RTTClient/font.ttf /home/pi/RTTClient/

# Create the start.sh script
echo "Creating start.sh..." | tee -a "$LOG_FILE"
cat << 'EOF' > /home/pi/RTTClient/start.sh
#!/bin/bash
cd /home/pi/RTTClient
./RTTClient
EOF

# Make start.sh and RTTClient executable
chmod +x /home/pi/RTTClient/start.sh
chmod +x /home/pi/RTTClient/RTTClient

# Setup autostart for RTTClient
echo "Configuring autostart..." | tee -a "$LOG_FILE"
mkdir -p /home/pi/.config/autostart
cat << 'EOF' > /home/pi/.config/autostart/rtt.desktop
[Desktop Entry]
Type=Application
Name=RTTClient
Exec=/home/pi/RTTClient/start.sh
EOF

# Inform the user that the setup is complete
echo "RTTClient setup complete. It will now start automatically on boot." | tee -a "$LOG_FILE"
