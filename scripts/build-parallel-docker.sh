#!/bin/bash

# Create a safe nix.gni for Linux
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

# Function to restore nix.gni on exit
cleanup() {
  echo "Restoring original nix.gni..."
  if [ -f nix.gni.bak ]; then
    mv nix.gni.bak nix.gni
  else
    rm -f nix.gni
  fi
}
trap cleanup EXIT

echo "Starting parallel builds for x64 and arm64..."

# Run x64 build
TARGET_ARCH=x64 SKIP_CONFIG=true ./scripts/build-incremental-docker.sh &

PID_X64=$!
# Run arm64 build
TARGET_ARCH=arm64 SKIP_CONFIG=true ./scripts/build-incremental-docker.sh &
PID_ARM64=$!

# Wait for both
wait $PID_X64
CODE_X64=$?

wait $PID_ARM64
CODE_ARM64=$?

if [ $CODE_X64 -ne 0 ]; then
  echo "x64 build failed"
fi

if [ $CODE_ARM64 -ne 0 ]; then
  echo "arm64 build failed"
fi

if [ $CODE_X64 -ne 0 ] || [ $CODE_ARM64 -ne 0 ]; then
  exit 1
fi

echo "Both builds completed successfully."
