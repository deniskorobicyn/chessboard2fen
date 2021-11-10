FROM tensorflow/tensorflow:2.2.0-gpu

RUN mkdir /src
WORKDIR /src

RUN apt-get update
RUN apt-get install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev
RUN apt-get install -y python3-pip

RUN apt install -y build-essential cmake git pkg-config libgtk-3-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3-dev python3-numpy \
    libtbb2 libtbb-dev libdc1394-22-dev libatlas-base-dev gfortran

RUN mkdir /opencv_build
RUN cd /opencv_build && git clone https://github.com/opencv/opencv.git
RUN cd /opencv_build && git clone https://github.com/opencv/opencv_contrib.git
RUN cd /opencv_build/opencv && git checkout 4.4.0
RUN cd /opencv_build/opencv_contrib && git checkout 4.4.0
RUN mkdir /opencv_build/opencv/build
RUN cd /opencv_build/opencv/build && cmake -D CMAKE_BUILD_TYPE=RELEASE \
    # -D WITH_CUDA= \
    # -D CUDA_ARCH_BIN="5.3,6.2,7.2" \
    # -D CUDA_ARCH_PTX="" \
    -D WITH_GSTREAMER=ON \
    -D WITH_LIBV4L=ON \
    -D BUILD_opencv_python3=ON \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_EXTRA_MODULES_PATH=/opencv_build/opencv_contrib/modules .. && \
    make -j8 && \
    make install

RUN apt-get install -y curl
RUN apt-get install -y python3.7
RUN cp /usr/bin/python3.7 /usr/bin/python3
RUN python3 --version
COPY requirements.txt /src/requirements.txt
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py --force-reinstall
RUN pip3.7 install -r requirements.txt