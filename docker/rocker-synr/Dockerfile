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
RUN Rscript -e 'install.packages(c("reticulate", "remotes", "janitor"))'
RUN remotes::install_version("rjson", version = "0.2.21", repos = "http://cran.us.r-project.org")
RUN Rscript -e 'install.packages(c("synapser", "synapserutils"), repos ="http://ran.synapse.org")'
USER root