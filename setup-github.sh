#!/bin/bash

# This script helps initialize and push your Jekyll Garden to GitHub Pages

echo "Setting up your Jekyll Garden for GitHub Pages deployment..."

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git first."
    exit 1
fi

# Initialize git repository if not already done
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
else
    echo "Git repository already initialized."
fi

# Add all files
echo "Adding files to git..."
git add .

# Commit changes
echo "Committing changes..."
git commit -m "Initial Jekyll Garden commit"

# Check if remote origin exists
if git remote | grep -q "origin"; then
    echo "Remote 'origin' already exists."
else
    # Add GitHub repository as remote
    echo "Adding GitHub repository as remote..."
    echo "Enter your GitHub username (default: qwertymarmot):"
    read github_username
    github_username=${github_username:-qwertymarmot}
    
    git remote add origin "https://github.com/$github_username/$github_username.github.io.git"
    echo "Remote 'origin' added: https://github.com/$github_username/$github_username.github.io.git"
fi

# Push to GitHub
echo "Pushing to GitHub..."
echo "This will push to the main branch. Continue? (y/n)"
read confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    git push -u origin main
    echo "Your Jekyll Garden has been pushed to GitHub!"
    echo "GitHub Actions will now build and deploy your site."
    echo "Your site will be available at https://$github_username.github.io/ in a few minutes."
else
    echo "Push cancelled. You can push manually with: git push -u origin main"
fi

echo "Setup complete!"
