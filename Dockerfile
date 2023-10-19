FROM pytorch/pytorch:1.9.0-cuda10.2-cudnn7-devel
RUN apt --allow-insecure-repositories update
RUN apt-get install --allow-unauthenticated wget -y
RUN apt-get install gfortran -y
RUN apt-get install emacs -y

# Create worker user
ARG UID_WORKER=1000
ARG GID_WORKER=1000
RUN groupadd -g $GID_WORKER worker
RUN useradd \
    --uid $UID_WORKER \
    --gid $GID_WORKER \
    --create-home \
    --home-dir /home/worker \
    worker

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
RUN echo "conda activate SkyNet" >> .bashrc

