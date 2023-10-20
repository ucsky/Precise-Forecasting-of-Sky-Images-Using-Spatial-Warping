FROM pytorch/pytorch:1.3-cuda10.1-cudnn7-devel # CRASH
# FROM pytorch/pytorch:1.9.0-cuda10.2-cudnn7-devel CRASH
# FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-devel Don't compile

# ENV TZ=Europe/Paris
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update
RUN apt install -y tzdata
RUN apt --allow-insecure-repositories update -y
RUN apt-get install --allow-unauthenticated wget -y
RUN apt-get install gfortran -y
RUN apt-get install emacs -y

# Create worker user.
ARG UID_WORKER=1000
ARG GID_WORKER=1000
RUN groupadd -g $GID_WORKER worker
RUN useradd \
    --uid $UID_WORKER \
    --gid $GID_WORKER \
    --create-home \
    --home-dir /home/worker \
    worker

# Switch to worker.
USER worker
WORKDIR /home/worker

COPY --chown=worker:worker ./correlation.py ./correlation.py
COPY --chown=worker:worker ./dataLoader.py ./dataLoader.py
COPY --chown=worker:worker ./LiteFlowNet.py ./LiteFlowNet.py
COPY --chown=worker:worker ./losses.py ./losses.py
COPY --chown=worker:worker ./skynet_Unet_model.py ./skynet_Unet_model.py
COPY --chown=worker:worker ./train.py ./train.py
COPY --chown=worker:worker ./warp.py ./warp.py
COPY --chown=worker:worker ./environment.yml ./environment.yml
COPY --chown=worker:worker ./requirements.txt ./requirements.txt
COPY --chown=worker:worker ./entrypoints ./entrypoints
COPY --chown=worker:worker ./network-sintel.pytorch ./network-sintel.pytorch

# Dowload miniconda install script. 
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh

# Install miniconda.
RUN bash miniconda.sh -b -p /home/worker/.miniconda3

# Add to path.
ENV PATH="/home/worker/.miniconda3/bin:${PATH}"

# Cleaning.
RUN rm miniconda.sh

# Add variables to .bashrc
RUN conda init bash

# Create env.
RUN conda env create -f environment.yml

# Make RUN commands use the new environment.
SHELL ["conda", "run", "-n", "SkyNet", "/bin/bash", "-c"]

# Checkout.
RUN which pip
RUN which python
RUN python --version
RUN conda env list

# Install python packages.
RUN pip install -U pip
RUN pip install -r requirements.txt

# Activate SkyNet by default.
RUN echo "conda activate SkyNet" >> .bashrc

