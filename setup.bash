#!/bin/bash -e
command -v gfortran >> /dev/null || sudo apt-get install gfortran
ACTIVATE_MINICONDA="${ACTIVATE_MINICONDA:-${HOME}/activate/miniconda3}" 
test -f ${ACTIVATE_MINICONDA} \
    && (. ${ACTIVATE_MINICONDA} && conda --version) \
    || (echo "ERROR: missing  ${ACTIVATE_MINICONDA}" && exit 1)
cd submodules/SkyNet
conda env list | egrep '^SkyNet\s+/' >> /dev/null \
    || conda env create -f environment.yml
eval "$(conda shell.bash hook)"
conda activate SkyNet
pip install -U pip
pip install -r requirements.txt
