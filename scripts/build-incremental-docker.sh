#!/bin/bash
set -e

# Architecture defaults to x64
TARGET_ARCH=${TARGET_ARCH:-x64}
if [ "$TARGET_ARCH" == "arm64" ]; then
  DOCKER_PLATFORM="linux/arm64"
else
  DOCKER_PLATFORM="linux/amd64"
fi

# Image name includes architecture
IMAGE_NAME="wrtc-linux-builder:$TARGET_ARCH"

# Ensure the builder image exists
if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" == "" ]]; then
  echo "Building Docker image $IMAGE_NAME..."
  docker build --platform $DOCKER_PLATFORM -t $IMAGE_NAME -f Dockerfile.builder .
fi

echo "Starting incremental build for $TARGET_ARCH..."
echo "Artifacts will be stored in 'build-linux-$TARGET_ARCH/' and 'prebuilds/linux-$TARGET_ARCH/'"

# Create a safe nix.gni for Linux (skip if requested)
if [ "$SKIP_CONFIG" != "true" ]; then
  cat <<EOF >nix.gni.linux
is_clang=true
use_lld=false
proprietary_codecs=true
rtc_use_h264=true
ffmpeg_branding="Chrome"
EOF

  # Swap nix.gni if it exists
  if [ -f nix.gni ]; then
    cp nix.gni nix.gni.bak
  fi
  mv nix.gni.linux nix.gni
fi

# Function to restore nix.gni on exit (only if we changed it)
cleanup() {
  if [ "$SKIP_CONFIG" != "true" ]; then
    echo "Restoring original nix.gni..."
    if [ -f nix.gni.bak ]; then
      mv nix.gni.bak nix.gni
    else
      rm -f nix.gni
    fi
  fi
}
trap cleanup EXIT

# Run the build container
# -v $(pwd):/app            : Mount current code (persists build artifacts on host)
# -v wrtc-linux-$TARGET_ARCH-node-modules:/app/node_modules : Isolate deps by arch
# --platform $DOCKER_PLATFORM    : Set platform
docker run --rm \
  --platform $DOCKER_PLATFORM \
  -e TARGET_ARCH=$TARGET_ARCH \
  -v "$(pwd):/app" \
  -v wrtc-linux-$TARGET_ARCH-node-modules:/app/node_modules \
  -w /app \
  $IMAGE_NAME \
  bash -c "npm install && npm run make-prebuilt"

echo "Build complete."
