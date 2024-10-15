# Download the Anaconda installer
curl -O https://repo.anaconda.com/archive/Anaconda3-2024.02-1-MacOSX-x86_64.sh

# Run the installer
zsh Anaconda3-2024.02-1-MacOSX-x86_64.sh
# Follow the prompts to complete the installation

# Initialize Anaconda (restart your shell or source the profile)
source ~/anaconda3/bin/activate
source ~/.zshrc
hash -r

# Verify installation
conda init
conda --version
