#!/bin/bash

# Generate data files for Jekyll Garden
# This script should be run before deploying to GitHub Pages

echo "Generating data files for Jekyll Garden..."

# Build the site with the local Gemfile to generate the data files
if BUNDLE_GEMFILE=Gemfile.local bundle exec jekyll build; then
    echo "Data files generated successfully!"
    echo "search-index.json and graph-data.json have been copied to the root directory."
    echo "Make sure to commit these files before deploying to GitHub Pages."
else
    echo "Error: Failed to generate data files. Please check the error messages above."
    exit 1
fi
