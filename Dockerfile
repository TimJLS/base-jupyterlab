FROM jupyter/scipy-notebook:python-3.8.8
ARG USER=maker
ENV NODE_OPTIONS="--max-old-space-size=4096" \
    HOME="/home/${USER}/projects"

USER root

RUN useradd -ms /bin/bash $USER
RUN mkdir ${HOME}
WORKDIR "${HOME}"

RUN sudo -E apt-get -y update && \
    sudo -E apt-get -y upgrade && \
    sudo -E apt-get install -qq -y curl gnupg vim
RUN sudo -E curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN sudo -E curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN sudo -E apt-get -y update
RUN sudo -E ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN sudo -E apt-get install -y g++ libboost-all-dev unixodbc-dev python-dev && pip install turbodbc

RUN conda install -c conda-forge pyodbc pycrypto
RUN pip install pymssql tableauserverclient jupyterlab-git


RUN jupyter labextension install nbdime-jupyterlab --no-build
RUN jupyter labextension install @jupyterlab/git --no-build
RUN jupyter lab build && \
        jupyter lab clean && \
        jlpm cache clean && \
        npm cache clean --force && \
        rm -rf $HOME/.node-gyp && \
        rm -rf $HOME/.local && \
    fix-permissions $CONDA_DIR $HOME
RUN jupyter server extension list

USER maker

# # Airflow
# ARG AIRFLOW_DEPS=""
# ARG AIRFLOW_VERSION=2.1.0
# ARG PYTHON_VERSION=$(python3 --version | cut -d " " -f 2 | cut -d "." -f 1-2)
# ARG CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
# RUN sudo -E apt-get install -y python3-dev default-libmysqlclient-dev build-essential libffi-dev
# RUN sudo -E apt-get install -y libsasl2-dev
# RUN pip install "apache-airflow[async,amazon,celery,cncf.kubernetes,docker,dask,elasticsearch,ftp,grpc,hashicorp,http,ldap,google,microsoft.azure,mysql,post,postgres,redis,sendgrid,sftp,slack,ssh,statsd,virtualenv]==1.10.14" \
# --constraint  "${CONSTRAINT_URL}"

# RUN pip install tornado==6.1
