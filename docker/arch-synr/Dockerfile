FROM archlinux:latest

# Install dependencies in a single RUN command
RUN pacman -Syu --noconfirm curl wget neovim python

#python3-venv python3-pip

# # Install Python packages
# RUN pip3 install synapseclient

# Install R packages
# R Dependencies: https://r-docs.synapse.org/articles/systemDependencies.html
# USER rstudio
# RUN Rscript -e 'install.packages("reticulate")'
# RUN Rscript -e 'install.packages("rjson")'
# RUN Rscript -e 'install.packages("janitor")'
# RUN Rscript -e 'install.packages("synapser", repos ="http://staging-ran.synapse.org")'
# RUN Rscript -e 'install.packages("synapserutils", repos ="http://staging-ran.synapse.org")'
# USER root
