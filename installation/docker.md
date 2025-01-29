# DPPO Docker Installation Guide

## Prerequisites
1. Install [Docker](https://docs.docker.com/get-docker/)
2. Install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
3. Ensure you have a CUDA-capable GPU


## Installation Steps

1. Build the Docker image:
```bash
docker build -t dppo .
```

2. Create directories on your host machine for data and logs:
```bash
mkdir -p /path/to/host/data
mkdir -p /path/to/host/log
```

3. Run the container:
```bash
docker run --gpus all \
#    -v /path/to/host/data:/workspace/data \
#    -v /path/to/host/log:/workspace/log \
    -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
    -it dppo
```

## Usage
Once inside the container, you can run experiments as explained in the main readme