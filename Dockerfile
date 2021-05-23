FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

ARG USER_NAME
ARG USER_UID
ARG USER_GID

# Install basics
RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends \
        build-essential \
        cmake \
        ca-certificates \
        git \
        gdb \
        valgrind \
        wget && \
    rm -rf /var/lib/apt/lists/*

# Install OpenCV prerequisites
RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends \
        libgtk2.0-dev \
        pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Install OpenCV
ENV OPENCV_VERSION="4.5.2"
RUN wget https://github.com/opencv/opencv/archive/refs/tags/$OPENCV_VERSION.tar.gz && \
    tar -xvzf $OPENCV_VERSION.tar.gz && \
    cd opencv-$OPENCV_VERSION && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    cd ../.. && \
    rm -r opencv-$OPENCV_VERSION && \
    rm $OPENCV_VERSION.tar.gz

# https://code.visualstudio.com/docs/remote/containers-advanced#_creating-a-nonroot-user
# https://github.com/moby/moby/issues/5419#issuecomment-41478290
RUN groupadd --gid $USER_GID $USER_NAME && \
    useradd --no-log-init --uid $USER_UID --gid $USER_GID --create-home $USER_NAME

USER $USER_NAME
