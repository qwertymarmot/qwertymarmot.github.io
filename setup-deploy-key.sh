#!/bin/bash

# This script helps generate and set up a deploy key for GitHub Actions

echo "Setting up deploy key for GitHub Actions..."

# Check if ssh-keygen is installed
if ! command -v ssh-keygen &> /dev/null; then
    echo "Error: ssh-keygen is not installed. Please install OpenSSH first."
    exit 1
fi

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh

# Generate SSH key pair
echo "Generating SSH key pair..."
ssh-keygen -t ed25519 -f ~/.ssh/github_deploy_key -N "" -C "github-actions-deploy-key"

# Display the public key
echo ""
echo "=== PUBLIC KEY (Add this as a Deploy Key in your GitHub repository) ==="
echo "1. Go to https://github.com/qwertymarmot/qwertymarmot.github.io/settings/keys"
echo "2. Click 'Add deploy key'"
echo "3. Title: GitHub Actions Deploy Key"
echo "4. Key: (copy the key below)"
echo "5. Check 'Allow write access'"
echo "6. Click 'Add key'"
echo ""
cat ~/.ssh/github_deploy_key.pub
echo ""
echo "=== END PUBLIC KEY ==="
echo ""

# Display the private key
echo "=== PRIVATE KEY (Add this as a Secret in your GitHub repository) ==="
echo "1. Go to https://github.com/qwertymarmot/qwertymarmot.github.io/settings/secrets/actions"
echo "2. Click 'New repository secret'"
echo "3. Name: DEPLOY_KEY"
echo "4. Value: (copy the key below, including BEGIN and END lines)"
echo "5. Click 'Add secret'"
echo ""
cat ~/.ssh/github_deploy_key
echo ""
echo "=== END PRIVATE KEY ==="
echo ""

echo "Setup complete!"
echo "After adding both keys to your GitHub repository, the GitHub Actions workflow will be able to deploy your site."
