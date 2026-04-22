#!/bin/bash
set -e

ARCH="aarch64"
PREFIX="$(pwd)/build/$ARCH"
JOBS=$(nproc)

# Use native OR cross
# For native ARM64:
CC="gcc"
CXX="g++"

# For cross (uncomment if building on x86_64):
# CC="aarch64-linux-gnu-gcc"
# CXX="aarch64-linux-gnu-g++"
# CROSS_PREFIX="aarch64-linux-gnu-"

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

########################################
# Build dav1d
########################################
build_dav1d() {
    if [ ! -d "dav1d" ]; then
        git clone https://code.videolan.org/videolan/dav1d.git
    fi

    cd dav1d
    rm -rf build

    meson setup build \
        --prefix="$PREFIX" \
        --buildtype=release \
        --default-library=static \
        -Denable_tests=false

    ninja -C build -j$JOBS
    ninja -C build install
    cd ..
}

########################################
# Build FFmpeg
########################################
build_ffmpeg() {
    cd ffmpeg

    ./configure \
        --prefix="$PREFIX" \
        --target-os=linux \
        --arch=$ARCH \
        --enable-gpl \
        --enable-libdav1d \
        --enable-static \
        --disable-shared \
        --disable-debug \
        --disable-doc \
        --disable-ffplay \
        --disable-avdevice \
        --disable-network \
        --disable-everything \
        \
        --enable-avcodec \
        --enable-avformat \
        --enable-avutil \
        --enable-swscale \
        --enable-swresample \
        \
        --enable-decoder=h264,hevc,vp8,vp9,av1 \
        --enable-parser=h264,hevc,vp9,av1 \
        --enable-demuxer=mov,matroska,webm,mp3,wav,flac \
        --enable-protocol=file \
        \
        --extra-cflags="-O2 -fPIC" \
        --extra-ldflags="-L$PREFIX/lib"

    make clean
    make -j$JOBS
    make install

    cd ..
}

########################################
# Clone FFmpeg if needed
########################################
if [ ! -d "ffmpeg" ]; then
    git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
fi

########################################
# Run build
########################################
echo "Building for Linux ARM64..."

build_dav1d
build_ffmpeg

echo "Done. Output in: $PREFIX"
