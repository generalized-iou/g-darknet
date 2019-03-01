# OpenCV

    sudo apt-get install -y build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev

    wget https://github.com/opencv/opencv/archive/3.4.0.zip
    unzip 3.4.0.zip
    cd opencv-3.4.0
    mkdir build
    cd build
    cmake -D CMAKE_BUILD_TYPE=Release ..
    make -j8
    sudo make install

# Darknet

    git clone ...
    make
