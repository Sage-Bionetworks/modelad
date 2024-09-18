FROM rocker/tidyverse:4.3.3


RUN apt-get clean all && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        curl \
        neovim \
        python3-pip \
        python3-venv && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install synapseclient

USER rstudio
RUN Rscript -e 'install.packages("reticulate")'
RUN Rscript -e 'install.packages("rjson")'
RUN Rscript -e 'install.packages("janitor")'
RUN Rscript -e 'install.packages("synapser", repos ="http://staging-ran.synapse.org")'
RUN Rscript -e 'install.packages("synapserutils", repos ="http://staging-ran.synapse.org")'
USER root
