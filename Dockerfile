FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    gcc-14-aarch64-linux-gnu \
    g++-14-aarch64-linux-gnu \
    cmake ninja-build rsync openssh-client python3 \
    libglib2.0-0t64 \
    && rm -rf /var/lib/apt/lists/*