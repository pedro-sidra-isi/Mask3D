FROM nvidia/cuda:11.6.1-devel-ubuntu20.04

ENV PATH="/root/conda/bin:${PATH}"
ARG PATH="/root/conda/bin:${PATH}"


SHELL ["/bin/bash", "-c"]

RUN apt-get update \
    && apt-get install -y git curl wget build-essential ninja-build libsparsehash-dev

RUN wget -O Mambaforge.sh  "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
RUN bash Mambaforge.sh -b -p "${HOME}/conda" \
  && source "${HOME}/conda/etc/profile.d/conda.sh" \
  && source "${HOME}/conda/etc/profile.d/mamba.sh" \
  && conda init bash

RUN conda install mamba -c conda-forge

COPY . /Mask3D
WORKDIR /Mask3D

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6"

RUN mamba env create -f environment.yml

SHELL ["/bin/bash", "-c", "conda", "activate", "mask3d_cuda113", "-c"]

RUN pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 --extra-index-url https://download.pytorch.org/whl/cu113
RUN pip install torch-scatter -f https://data.pyg.org/whl/torch-1.12.1+cu113.html
RUN pip install 'git+https://github.com/facebookresearch/detectron2.git@710e7795d0eeadf9def0e7ef957eea13532e34cf' --no-deps

WORKDIR /Mask3D/third_party

RUN git clone --recursive "https://github.com/NVIDIA/MinkowskiEngine" && \
    cd MinkowskiEngine && \
    git checkout 02fc608bea4c0549b0a7b00ca1bf15dee4a0b228 && \
    python setup.py install --force_cuda --blas=openblas

RUN git clone https://github.com/ScanNet/ScanNet.git &&\
    cd ScanNet/Segmentator &&\
    git checkout 3e5726500896748521a6ceb81271b0f5b2c0e7d2 &&\
    make
RUN cd pointnet2 && python setup.py install

RUN pip install pytorch-lightning==1.7.2
