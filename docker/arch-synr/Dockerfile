FROM archlinux:latest

# Set working directory to /tmp for better performance
WORKDIR /tmp

# Install dependencies in a single RUN command
RUN pacman -Syu --noconfirm r neovim python-pip python-pipx 

# Install Python packages
RUN pipx install synapseclient

# Install R packages
RUN Rscript -e 'install.packages(c("reticulate", "rjson", "janitor"), repos="https://cloud.r-project.org/")' && \
    Rscript -e 'install.packages(c("synapser", "synapserutils"), repos="http://staging-ran.synapse.org")'

# Expose the common default port
EXPOSE 443

# Set environment variables for better debugging and logging
ENV TERM=xterm-256color \
    LOG_LEVEL=INFO
