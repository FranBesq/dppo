# Use NVIDIA CUDA base image
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3.8 \
    python3.8-dev \
    python3-pip \
    wget \
    unzip \
    patchelf \
    libosmesa6-dev \
    libgl1-mesa-glx \
    libglfw3 \
    libglew2.1 \
    cmake \
    build-essential \
    pkg-config \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh
ENV PATH=/opt/conda/bin:$PATH

# Create conda environment
RUN conda create -n dppo python=3.8 -y
SHELL ["conda", "run", "-n", "dppo", "/bin/bash", "-c"]

# Clone repository
RUN git clone https://github.com/irom-lab/dppo.git \
    && cd dppo

# Install core dependencies and task-specific dependencies (excluding furniture)
WORKDIR /workspace/dppo
RUN pip install -e . \
    && pip install -e ".[gym]" \
    && pip install -e ".[robomimic]" \
    && pip install -e ".[d3il]"

# Install MuJoCo
RUN mkdir -p /root/.mujoco \
    && wget https://github.com/deepmind/mujoco/releases/download/2.1.0/mujoco210-linux-x86_64.tar.gz \
    && tar -xf mujoco210-linux-x86_64.tar.gz -C /root/.mujoco \
    && rm mujoco210-linux-x86_64.tar.gz

# Set environment variables
ENV LD_LIBRARY_PATH=/root/.mujoco/mujoco210/bin:${LD_LIBRARY_PATH}
ENV MUJOCO_PY_MUJOCO_PATH=/root/.mujoco/mujoco210
ENV DPPO_DATA_DIR=/workspace/data
ENV DPPO_LOG_DIR=/workspace/log

# Create directories for data and logs
RUN mkdir -p /workspace/data /workspace/log

# Set default command to activate conda environment
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "dppo"]
CMD ["/bin/bash"]