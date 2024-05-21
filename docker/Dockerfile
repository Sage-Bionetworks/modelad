FROM rocker/tidyverse:latest

LABEL source="https://github.com/xx/Dockerfile"
LABEL maintainer="richard.yaxley@sagebase.org"

# Install system dependencies for R packages: https://r-docs.synapse.org/articles/systemDependencies.html
RUN apt-get clean all && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        curl \ 
        libcurl4-openssl-dev \
        libssl-dev \
        libffi-dev \
        zlib1g-dev \
        dpkg-dev \
        python3-pip \
        python3-venv \
        python3-ipython \
        python3-matplotlib && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install synapseclient

# Install R packages directly
USER rstudio
RUN Rscript -e 'install.packages(c("reticulate", "rjson"))'
RUN Rscript -e 'install.packages("synapser", repos ="http://staging-ran.synapse.org")'
RUN Rscript -e 'install.packages("synapserutils", repos ="http://staging-ran.synapse.org")'
USER root
