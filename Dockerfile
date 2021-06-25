FROM jupyter/scipy-notebook:python-3.8.8
ARG USER=maker
ENV NODE_OPTIONS="--max-old-space-size=4096" \
    HOME="/home/${USER}/projects"

USER root

RUN useradd -ms /bin/bash $USER && \
    mkdir ${HOME}
WORKDIR "${HOME}"

RUN sudo -E apt-get -y update && \
    sudo -E apt-get -y upgrade && \
    sudo -E apt-get install -qq -y --no-install-recommends curl gnupg vim && \
    sudo -E curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    sudo -E curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    sudo -E apt-get -y update && \
    sudo -E ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql17 && \
    sudo -E apt-get install -y --no-install-recommends g++ libboost-all-dev unixodbc-dev python-dev && \
    pip install --no-cache-dir turbodbc && \
    conda install -c conda-forge pyodbc pycrypto && \
    pip install --no-cache-dir pymssql tableauserverclient jupyterlab-git

RUN jupyter labextension install nbdime-jupyterlab --no-build && \
    jupyter labextension install @jupyterlab/git --no-build && \
    jupyter lab build && \
        jupyter lab clean && \
        jlpm cache clean && \
        npm cache clean --force && \
        rm -rf $HOME/.node-gyp && \
        rm -rf $HOME/.local && \
    fix-permissions $CONDA_DIR $HOME

USER maker
