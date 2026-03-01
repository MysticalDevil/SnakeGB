FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG CMAKE_VERSION=4.1.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libasound2-dev \
    libgl1-mesa-dev \
    libpulse-dev \
    libsensors-dev \
    libvulkan-dev \
    libxcb-cursor0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-xinerama0 \
    libxkbcommon-x11-0 \
    ninja-build \
    pkg-config \
    python3 \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-multimedia-dev \
    qt6-shadertools-dev \
    qt6-tools-dev-tools \
    qt6-sensors-dev \
    xvfb \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    arch="$(uname -m)"; \
    case "${arch}" in \
      x86_64) cmake_arch="linux-x86_64" ;; \
      aarch64) cmake_arch="linux-aarch64" ;; \
      *) echo "unsupported architecture: ${arch}" >&2; exit 1 ;; \
    esac; \
    curl -fL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-${cmake_arch}.tar.gz" \
      -o /tmp/cmake.tar.gz; \
    tar -xzf /tmp/cmake.tar.gz -C /opt; \
    ln -sf "/opt/cmake-${CMAKE_VERSION}-${cmake_arch}/bin/cmake" /usr/local/bin/cmake; \
    ln -sf "/opt/cmake-${CMAKE_VERSION}-${cmake_arch}/bin/ctest" /usr/local/bin/ctest; \
    ln -sf "/opt/cmake-${CMAKE_VERSION}-${cmake_arch}/bin/cpack" /usr/local/bin/cpack; \
    rm -f /tmp/cmake.tar.gz; \
    cmake --version

WORKDIR /workspace

COPY scripts/ci/run_gh_sim.sh /usr/local/bin/run-gh-sim
RUN chmod +x /usr/local/bin/run-gh-sim

ENTRYPOINT ["/usr/local/bin/run-gh-sim"]
