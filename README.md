# This files are for setup raspberry for RTTClient for Falcon BMS 4.36

Run this Script first
wget -O - https://raw.githubusercontent.com/clauridsen/RTT/main/build.sh?token=GHSAT0AAAAAABUKBAGBMUNYYCQIRSF6WQ56YTWFGGQ | bash

If this Error
/RakNet-master/Source/ReplicaManager3.cpp:141:61: Comparison between pointer and integer ('RakNet::Connection_RM3 *' and 'int')

Then change

if (GetConnectionByGUID(participantListIn[index], worldId)==false)

to

if (GetConnectionByGUID(participantListIn[index], worldId)==nullptr)
