FROM jupyter/scipy-notebook

ARG HTTP_PROXY="http://10.40.40.245:3128"
COPY apt.conf /etc/apt/apt.conf
ENV NODE_OPTIONS="--max-old-space-size=4096"

RUN pip config set "global.proxy" ${HTTP_PROXY}
RUN pip install --upgrade jupyterlab-git
RUN pip install tableauserverclient

RUN npm config set proxy ${HTTP_PROXY}
RUN npm config set https-proxy ${HTTP_PROXY}

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

#sql driver install
USER root

RUN sudo apt-get -y update
RUN sudo apt-get -y upgrade
RUN sudo apt-get install -y curl
RUN sudo apt-get install -y gnupg
RUN sudo curl -x ${HTTP_PROXY} https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN sudo curl -x ${HTTP_PROXY} https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN sudo apt-get -y update
RUN sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17

RUN conda config --set proxy_servers.http ${HTTP_PROXY}
RUN conda config --set proxy_servers.https ${HTTP_PROXY}
RUN conda install -y -c conda-forge pyodbc
RUN conda install -y -c conda-forge pycrypto
RUN conda install -y -c anaconda pymssql
RUN conda install -y -c conda-forge turbodbc
# Airflow
ARG AIRFLOW_DEPS=""
ARG AIRFLOW_VERSION=1.10.14
ARG PYTHON_VERSION=3.8
ARG CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
RUN sudo apt-get install -y python3-dev default-libmysqlclient-dev build-essential libffi-dev
RUN sudo apt-get install -y libsasl2-dev
RUN pip install "apache-airflow[async,amazon,celery,cncf.kubernetes,docker,dask,elasticsearch,ftp,grpc,hashicorp,http,ldap,google,microsoft.azure,mysql,post,postgres,redis,sendgrid,sftp,slack,ssh,statsd,virtualenv]==1.10.14" \
--constraint  "${CONSTRAINT_URL}"

RUN pip install tornado==6.1
