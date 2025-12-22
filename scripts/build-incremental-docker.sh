#!/bin/bash
set -e

# Image name
IMAGE_NAME="wrtc-linux-builder"

# Ensure the builder image exists
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "Building Docker image $IMAGE_NAME..."
    docker build --platform linux/amd64 -t $IMAGE_NAME -f Dockerfile.builder .
fi

echo "Starting incremental build..."
echo "Artifacts will be stored in 'build-linux-x64/' and 'prebuilds/linux-x64/'"

# Create a safe nix.gni for Linux
cat <<EOF > nix.gni.linux
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

# Function to restore nix.gni on exit (success or failure)
cleanup() {
    echo "Restoring original nix.gni..."
    if [ -f nix.gni.bak ]; then
        mv nix.gni.bak nix.gni
    else
        rm nix.gni
    fi
}
trap cleanup EXIT

# Run the build container
# -v $(pwd):/app            : Mount current code (persists build artifacts on host)
# -v wrtc-linux-node-modules:/app/node_modules : Isolate Linux deps from Mac deps
# --platform linux/amd64    : Force x64 environment
docker run --rm \
    --platform linux/amd64 \
    -v "$(pwd):/app" \
    -v wrtc-linux-node-modules:/app/node_modules \
    -w /app \
    $IMAGE_NAME \
    bash -c "npm install && npm run make-prebuilt"

echo "Build complete."
