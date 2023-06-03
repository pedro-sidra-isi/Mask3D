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
RUN mamba install python==3.11
RUN mamba install openblas-devel -c anaconda


RUN pip install torch torchvision --extra-index-url https://download.pytorch.org/whl/cu116
RUN pip install torch-scatter -f https://data.pyg.org/whl/torch-1.13.1+cu116.html

RUN pip install ninja==1.10.2.3
RUN pip install pytorch-lightning fire imageio tqdm wandb python-dotenv pyviz3d scipy plyfile scikit-learn trimesh loguru albumentations volumentations

RUN pip install antlr4-python3-runtime==4.8
RUN pip install black==21.4b2
RUN pip install omegaconf==2.0.6 hydra-core==1.0.5 --no-deps
RUN pip install 'git+https://github.com/facebookresearch/detectron2.git@710e7795d0eeadf9def0e7ef957eea13532e34cf' --no-deps

COPY . /Mask3D
WORKDIR /Mask3D

RUN cd /Mask3D/third_party/pointnet2 && python setup.py install

