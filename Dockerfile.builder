# Dockerfile.builder
# A persistent build environment for incremental builds
FROM node:20-bookworm

# Install build dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    git \
    pkg-config \
    zlib1g-dev \
    patchelf \
    curl \
    cmake \
    build-essential \
    clang \
    ninja-build \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /app

# Set environment variables for the build
ENV TARGET_ARCH=x64
ENV CC=clang
ENV CXX=clang++

# Entrypoint to keep container ready or run commands
CMD ["/bin/bash"]
