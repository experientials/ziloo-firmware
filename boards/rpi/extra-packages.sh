FIRST_USER_PASS="thepia1"

# Install ML packages
sudo apt install \
  mc build-essential cmake \
  python3 idle3 python3-tk python3-pygame \
  libgtk2.0-dev libgtk-3-dev \
  libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev \
  libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
  libxvidcore-dev libx264-dev \
  libatlas-base-dev gfortran \
  libgtk-3-dev \
  libboost-all-dev \
  python3-scipy python3-skimage \
  libzbar0 python-zbar zbar-tools \
  python-opencv
 # libzbar-dev
 
# Audio

pip3 install simpleaudio

 # Tools
 sudo apt install \
   parted qemu-user-static zipdosfstools bsdtar rsync
