FROM rocker/tidyverse:4.3.3
LABEL source="https://github.com/Sage-Bionetworks/modelad/Dockerfile"
LABEL maintainer="richard.yaxley@sagebase.org"

# Install system dependencies for R packages: https://r-docs.synapse.org/articles/systemDependencies.html
RUN apt-get clean all && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        curl \
        # libcurl4-openssl-dev \
        # libssl-dev \
        # libffi-dev \
        # zlib1g-dev \
        # dpkg-dev \
        python3-pip \
        python3-venv && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install synapseclient

# Install R packages directly
USER rstudio
RUN Rscript -e 'install.packages("reticulate")'
RUN Rscript -e 'install.packages("rjson")'
RUN Rscript -e 'install.packages("janitor")'
RUN Rscript -e 'install.packages("synapser", repos ="http://staging-ran.synapse.org")'
RUN Rscript -e 'install.packages("synapserutils", repos ="http://staging-ran.synapse.org")'
USER root
