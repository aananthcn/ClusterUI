#!/usr/bin/env bash
set -euo pipefail

# Arguments to this script
RPI_IP="${1:-192.168.10.10}"
RPI_USER="${2:-aananth}"

PROJECT_DIR="$(pwd)"
BUILD_DIR="${PROJECT_DIR}/build/rpi5"
REMOTE_DIR="/home/${RPI_USER}/cluster"

CONTAINER_NAME="rpi5-builder"

echo "==> Checking Docker container..."
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "    Container not found. Creating..."
    docker run -dit \
        -v ~/labs/ui/qt/rpi5:/work \
        -v ~/Qt:/Qt \
        --name "${CONTAINER_NAME}" \
        ubuntu:24.04 bash
else
    echo "    Container exists. Starting if not running..."
    docker start "${CONTAINER_NAME}" 2>/dev/null || true
fi

echo "==> Ensuring toolchain is installed inside container..."
docker exec "${CONTAINER_NAME}" bash -c "
    if ! command -v cmake &>/dev/null || \
       ! command -v aarch64-linux-gnu-g++-14 &>/dev/null || \
       ! dpkg -l libglib2.0-0 &>/dev/null; then
        echo '    Tools missing, installing...'
        apt update && apt install -y \
            gcc-14-aarch64-linux-gnu \
            g++-14-aarch64-linux-gnu \
            cmake ninja-build rsync openssh-client python3 \
            libglib2.0-0
    else
        echo '    Tools already installed, skipping.'
    fi
"
echo "==> Configuring and building inside container..."
docker exec "${CONTAINER_NAME}" bash -c "
    cd /work/ClusterUI
    cmake -S . \
          -B build/rpi5 \
          --toolchain rpi5-toolchain.cmake \
          -DCMAKE_BUILD_TYPE=Release \
          -GNinja \
          -DQT_HOST_PATH=/Qt/6.8.3/gcc_64/ \
          -DQT_HOST_PATH_CMAKE_DIR=/Qt/6.8.3/gcc_64/lib/cmake \
          -DCMAKE_PREFIX_PATH=/work/root/usr/lib/aarch64-linux-gnu/cmake \
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
    export QT_QPA_PLATFORM=eglfs
    export QSG_RHI_BACKEND=opengl
    export QT_QPA_EGLFS_KMS_CONFIG=/home/${RPI_USER}/cluster/eglfs.json

    pkill -f cluster-ui || true
    sleep 0.2
    nohup ${REMOTE_DIR}/cluster-ui > /tmp/cluster.log 2>&1 &
    echo "Started cluster-ui. Logs: /tmp/cluster.log"
REMOTE

echo "==> Done."