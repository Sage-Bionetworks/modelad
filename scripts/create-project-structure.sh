# Create Project Directory Structure
# modelad/
# ├── data/
# │   ├── raw/            # For raw data files
# │   ├── processed/      # For processed data files
# ├── notebooks/          # For Jupyter/RMarkdown notebooks
# ├── scripts/            # For reusable scripts and functions
# ├── results/            # For results and output files
# ├── logs/               # For log files
# ├── .gitignore          # To exclude files from version control
# ├── environment.yml     # Conda environment configuration
# ├── Dockerfile          # Docker configuration file
# └── README.md           # Project documentation
mkdir -p \
    modelad/data/raw \
    modelad/data/processed \
    modelad/notebooks \
    modelad/scripts \
    modelad/results \
    modelad/logs
touch modelad/.gitignore modelad/README.md
