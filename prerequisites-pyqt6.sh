### Dev dependencies
sudo apt install -y curl

sudo apt install -y sqlite3
sudo apt install -y f2c

sudo apt-get install -y autoconf
sudo apt-get install -y libtool
sudo apt-get install -y libgl1-mesa-dev
sudo apt-get install -y libglu1-mesa-dev
sudo apt install -y libfontconfig1-dev libfreetype6-dev libx11-dev libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libxcb-cursor-dev libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev

# TODO (pradeep): Do we need this for unicode support?
sudo apt-get install -y libicu-dev

# TODO (pradeep): Check if these dependencies (from Qt5/PyQt5) are still valid for Qt6/PyQt6
sudo apt-get install -y libffi-dev gfortran uglifyjs make pkg-config npm cmake
sudo apt install -y zlib1g 
sudo apt install -y zlib1g-dev

sudo npm install -g less

### NINJA (alternate to cmake that Qt uses)
sudo apt-get install -y ninja-build
# put ninja to bin

### NVM
# https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# reload bashrc
nvm install v18.5.0
nvm use v18.5.0

# (optional) Makes arrow keys work ?
sudo apt-get install -y libncurses5-dev
pip install readline --no-cache-dir
