FROM pytorch/pytorch:1.9.0-cuda10.2-cudnn7-devel
RUN apt --allow-insecure-repositories update
RUN apt-get install --allow-unauthenticated wget -y
RUN apt-get install gfortran -y
RUN apt-get install emacs -y

# Create worker user
ARG UID
ARG GID
ENV UID ${UID_WORKER:-1000}
ENV GID ${GID_WORKER:-1000}
RUN useradd \
      --uid $UID \
      --create-home \
      --home-dir /home/worker \
    worker

USER worker
WORKDIR /home/worker

COPY ./correlation.py ./correlation.py
COPY ./dataLoader.py ./dataLoader.py
COPY ./LiteFlowNet.py ./LiteFlowNet.py
COPY ./losses.py ./losses.py
COPY ./skynet_Unet_model.py ./skynet_Unet_model.py
COPY ./train.py ./train.py
COPY ./warp.py ./warp.py
COPY ./environment.yml ./environment.yml
COPY ./requirements.txt ./requirements.txt

# Téléchargez le script d'installation de Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh

# Installez Miniconda en utilisant le script téléchargé
RUN bash miniconda.sh -b -p /home/worker/.miniconda3

# Ajoutez le chemin d'installation de Miniconda à la variable PATH
ENV PATH="/home/worker/.miniconda3/bin:${PATH}"

# Nettoyez les fichiers temporaires
RUN rm miniconda.sh

# Add variables to .bashrc
RUN conda init bash

# Create env.
RUN conda env create -f environment.yml

# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "SkyNet", "/bin/bash", "-c"]

# For dbug
RUN which pip
RUN which python
RUN python --version
RUN conda env list

RUN pip install -U pip
RUN pip install -r requirements.txt

