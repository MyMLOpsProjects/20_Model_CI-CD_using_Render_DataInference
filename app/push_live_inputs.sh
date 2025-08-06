#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

echo "🚀 Starting Git sync process for live data..."
echo "📂 Current directory: $(pwd)"

# Check if the data file exists before doing anything.
if [ ! -f live_inputs.csv ]; then
    echo "❌ live_inputs.csv not found. Nothing to push."
    exit 0
fi

# Initialize git if not already a repo (for the first run in a fresh environment)
if [ ! -d .git ]; then
    echo "🤔 .git directory not found. Initializing a new repository..."
    git init
    git remote add origin https://$GITHUB_PAT@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git

    # Create an empty initial commit so that commands like 'stash' can work.
    git commit --allow-empty -m "Initial commit for CI environment setup"
fi

# Set Git identity for the commit
git config user.email "pycsrbypankaj@gmail.com"
git config user.name "pycsr"

# Add the new/modified live_inputs.csv to the staging area
git add live_inputs.csv

# Stash changes so we can safely switch branches
echo "🗄️ Stashing new live_inputs.csv to switch branches safely."
git stash

# Define branch name
BRANCH_NAME="live-data-branch"

# Fetch remote references
git fetch origin

# Check if remote branch exists
echo "🔍 Checking if remote branch '$BRANCH_NAME' exists..."
if git ls-remote --exit-code --heads origin $BRANCH_NAME > /dev/null; then
    echo "✅ Branch '$BRANCH_NAME' exists. Checking it out..."
    git switch $BRANCH_NAME
    git pull origin $BRANCH_NAME --rebase=false --allow-unrelated-histories || true
else
    echo "🆕 Branch '$BRANCH_NAME' does not exist. Creating it..."
    git switch -c $BRANCH_NAME
fi

# Re-apply stashed changes
echo "🍾 Applying stashed changes..."
git stash pop || true  # Don't fail if there's nothing to pop

# Stage the file again
git add live_inputs.csv

# Commit only if there are actual changes
if ! git diff-index --quiet HEAD --; then
    echo "📝 Changes detected. Committing..."
    git commit -m "Update live_inputs.csv on $(date '+%Y-%m-%d %H:%M:%S')"

    echo "🚀 Pushing to origin..."
    git push -u origin $BRANCH_NAME
    echo "✅ live_inputs.csv pushed successfully!"
else
    echo "ℹ️ No changes to commit. The new data is identical to the last version."
fi
