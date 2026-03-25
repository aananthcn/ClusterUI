# ClusterUI
A sample instrument cluster application developed using Qt.

# Getting Started
## Target Setup
On the Raspberry Pi5, install Raspbian OS and followed by the following:
```
sudo apt install -y qt6-base-dev qt6-declarative-dev \
  qt6-multimedia-dev libgles2-mesa-dev \
  libgbm-dev libdrm-dev libegl-dev

sudo apt install -y qt6-wayland \
  qt6-wayland-dev libwayland-dev libxkbcommon-dev \
  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  libfontconfig1-dev libfreetype-dev
```

## Host Setup for Development
On the PC install following packages:
```
sudo apt update && sudo apt install -y \
  build-essential cmake ninja-build git \
  gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
  libgl1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev \
  libgbm-dev libdrm-dev libwayland-dev \
  libxkbcommon-dev libfontconfig1-dev \
  libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
  python3 python3-pip curl ssh rsync docker.io
```
Then install Qt by following the instructions in the link:
https://doc.qt.io/qt-6/get-and-install-qt-cli.html


#### Copy RPi5 libs to PC for Cross Compilation and Linking
Follow these steps if you want to cross compile the app from the PC and deploy it easily.
```
mkdir -p ~/sdk/rpi5/root
rsync -avz <pi_user>@<rpi5-ip>:/lib ~/sdk/rpi5/root \
  --rsync-path="sudo rsync"

rsync -avz <pi_user>@<rpi5-ip>:/usr ~/sdk/rpi5/root \
  --rsync-path="sudo rsync" \
  --exclude '/usr/man' --exclude '/usr/share/doc'
```

Run following command to know the version of the Qt on RPi5 target:
```
ssh aananth@192.168.10.10 "qmake6 --version || qmake --version || dpkg -l | grep qt6-base"
```

Then download and install the exact version of Qt from on host in ~/Qt/<version>/gcc_64/


## Build
```
cmake -S . -B build/pc  -DCMAKE_PREFIX_PATH=~/Qt/6.11.0/gcc_64/  -GNinja 
cmake --build build/pc/ -j16 
```
 
## Run 
### On PC
```
./build/pc/cluster-ui 
```

### On Target (RPi5)
The deploy script builds the app inside a Docker container, deploys it to the RPi5,
stops the Wayland display manager, and launches the app using EGLFS directly on the framebuffer.
```
./scripts/deploy.sh [rpi5-ip] [rpi5-user]
```
Default IP is `192.168.10.10` and default user is `aananth`. To override:
```
./scripts/deploy.sh 192.168.10.20 pi
```

#### Passwordless sudo on RPi5
The deploy script stops the display manager over SSH. Add this to `/etc/sudoers`
on the Pi via `sudo visudo` to avoid password prompts:
```
<pi_user> ALL=(ALL) NOPASSWD: /bin/systemctl stop gdm3, /bin/systemctl stop lightdm
```

## Clean
```
rm -rf build/pc
rm -rf build/rpi5
```