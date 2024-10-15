#!/usr/bin/env zsh
# curl <conda-installer-name>-latest-MacOSX-x86_64.sh
# zsh ~/Anaconda3-latest-MacOSX-x86_64.sh
~/anaconda3/bin/conda init zsh
conda env create -f modelad/environment.yml
conda activate modelad