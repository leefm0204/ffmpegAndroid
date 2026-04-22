#!/bin/bash
set -e

# Target setup
TARGET_ARCH="aarch64"
PREFIX="$FFMPEG_BUILD_DIR/$TARGET_ARCH"
ENABLED_CONFIG="
    --enable-avcodec
    --enable-avformat
    --enable-avutil
    --enable-swscale
    --enable-swresample
    --enable-static
    --enable-pic
    --enable-shared
    --enable-protocol=*
    --enable-demuxer=*
    --enable-parser=*
    --enable-bsf=*
"
DISABLED_CONFIG="
    --disable-debug
    --disable-doc
    --disable-ffplay
    --disable-ffprobe
"

echo -e "\e[1;32mCompiling FFmpeg for Linux ARM64...\e[0m"

cd "$FFMPEG_SOURCE_DIR"
./configure \
    --arch=$TARGET_ARCH \
    --target-os=linux \
    --prefix="$PREFIX" \
    --extra-cflags="-O2 -march=armv8-a -fPIC" \
    --extra-ldflags="-Wl,-z,relro -Wl,-z,now" \
    $ENABLED_CONFIG \
    $DISABLED_CONFIG

make -j$(nproc)
make install

echo -e "\e[1;32mFFmpeg build complete. Output in $PREFIX\e[0m"
