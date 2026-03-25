#!/usr/bin/env bash
set -euo pipefail

# Arguments to this script
RPI_IP="${1:-192.168.10.10}"
RPI_USER="${2:-aananth}"

# Always run the deploy script from ClusterUI folder.
PROJECT_DIR="$(pwd)"
RPI_SDK_DIR="$HOME/sdk/rpi5"
BUILD_DIR="${PROJECT_DIR}/build/rpi5"
REMOTE_DIR="/home/${RPI_USER}/cluster"

IMAGE_NAME="rpi5-builder:latest"

# Working directory check
if [ ! -d "$PROJECT_DIR/src" ]; then
    echo "Error: You must invoke this script from ClusterUI folder!" >&2
    exit 1
fi
echo "ClusterUI working folder: ${PROJECT_DIR}"
echo "Raspberry Pi5 SDK folder: ${RPI_SDK_DIR}"
echo ""

# Build image if not present
if ! docker image inspect "${IMAGE_NAME}" &>/dev/null; then
    echo "==> Building Docker image..."
    docker build -t "${IMAGE_NAME}" "${PROJECT_DIR}"
fi

echo "==> Configuring and building inside container..."
docker run --rm \
    --user "$(id -u):$(id -g)" \
    -v "${PROJECT_DIR}:/work" \
    -v "${RPI_SDK_DIR}:/sdk" \
    -v "$HOME/Qt:/Qt" \
    "${IMAGE_NAME}" bash -c "
        cd /work
        cmake -S . \
              -B build/rpi5 \
              --toolchain rpi5-toolchain.cmake \
              -DCMAKE_BUILD_TYPE=Release \
              -GNinja \
              -DQT_HOST_PATH=/Qt/6.8.3/gcc_64/ \
              -DQT_HOST_PATH_CMAKE_DIR=/Qt/6.8.3/gcc_64/lib/cmake \
              -DCMAKE_PREFIX_PATH=/sdk/root/usr/lib/aarch64-linux-gnu/cmake \
              -DQT_QMLIMPORTSCANNER_EXECUTABLE=/Qt/6.8.3/gcc_64/libexec/qmlimportscanner
        cmake --build build/rpi5 -j\$(nproc)
    "

echo "==> Deploying to ${RPI_USER}@${RPI_IP}:${REMOTE_DIR}..."
ssh "${RPI_USER}@${RPI_IP}" "mkdir -p ${REMOTE_DIR}"
rsync -avz --delete \
    "${BUILD_DIR}/cluster-ui" \
    "${RPI_USER}@${RPI_IP}:${REMOTE_DIR}/"

echo "==> Launching on RPi5..."
ssh "${RPI_USER}@${RPI_IP}" bash <<REMOTE
    # Stop Wayland/GDM so EGLFS can take the display
    sudo systemctl stop gdm3 || sudo systemctl stop lightdm || true
    sleep 1

    # Hide the hardware cursor
    sudo sh -c 'echo 0 > /sys/class/graphics/fbcon/cursor_blink' 2>/dev/null || true
    sudo sh -c 'echo 0 > /dev/input/mice' 2>/dev/null || true
    unclutter -idle 0 -root &
    export QT_QPA_EGLFS_HIDECURSOR=1

    export QT_QPA_PLATFORM=eglfs
    export QSG_RHI_BACKEND=opengl
    export QT_QPA_EGLFS_KMS_CONFIG=/home/${RPI_USER}/cluster/eglfs.json

    pkill -f cluster-ui || true
    sleep 0.2
    nohup ${REMOTE_DIR}/cluster-ui > /tmp/cluster.log 2>&1 &
    echo "Started cluster-ui. Logs: /tmp/cluster.log"
REMOTE

echo "==> Done."