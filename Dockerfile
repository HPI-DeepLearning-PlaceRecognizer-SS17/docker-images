FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04
LABEL maintainer="arthur@arthursilber.de"

# Configuration variables (defaults are set on first use to not break caching layers)
# ARG mxnetInstallTag
# ARG opencvInstallTag

# Install python 3 + required modules
# (because visual backprop needs python 3)
RUN apt-get update
RUN apt-get install -y \
	wget \
	build-essential \
	cmake \
	git \
	pkg-config \
	libopenblas-dev \
	python3 \
	python3-dev \
	graphviz

# Install pip
RUN wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py

# Install numpy
RUN pip install numpy

# Since there is no opencv for python3 already packaged, we need to build it
# Source: http://www.pyimagesearch.com/2016/10/24/ubuntu-16-04-how-to-install-opencv/
RUN apt-get install -y \
	libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
	libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
	libxvidcore-dev libx264-dev \
	libatlas-base-dev gfortran \
	liblapacke-dev

ARG opencvInstallTag
RUN git clone --depth 1 -b ${opencvInstallTag:-3.2.0} https://github.com/opencv/opencv /opencv
RUN mkdir /opencv/build
RUN cd /opencv/build && cmake \
	-D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D INSTALL_PYTHON_EXAMPLES=OFF \
	-D INSTALL_C_EXAMPLES=OFF \
	..
RUN cd /opencv/build && make -j4
RUN cd /opencv/build && make install
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# ToDo: matplotlib(?)

# Since we want to have a specific mxnet version, we need to build from source
ARG mxnetInstallTag
RUN git clone --depth 1 -b ${mxnetInstallTag:-master} --recursive https://github.com/dmlc/mxnet /mxnet

# Make mxnet and pythonbindings
RUN cd /mxnet && make -j4 USE_OPENCV=1 USE_BLAS=openblas USE_CUDA=1 USE_CUDA_PATH=/usr/local/cuda USE_CUDNN=1
RUN cd /mxnet/python && python3 setup.py install

