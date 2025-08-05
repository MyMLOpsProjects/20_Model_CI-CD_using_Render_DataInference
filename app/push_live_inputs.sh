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
    
    # --- THIS IS THE CRITICAL FIX ---
    # Create an empty initial commit so that commands like 'stash' can work.
    git commit --allow-empty -m "Initial commit for CI environment setup"
    # ---------------------------------
fi

# Set Git identity for the commit
git config user.email "pycsrbypankaj@gmail.com"
git config user.name "pycsr"

# 1. Add the new/modified live_inputs.csv to the staging area.
git add live_inputs.csv

# 2. Stash the staged changes. This "hides" the file and cleans the working directory.
echo "🗄️ Stashing new live_inputs.csv to switch branches safely."
git stash

# 3. Now that the directory is clean, fetch remote state and switch branches.
BRANCH_NAME="live-data-branch"
git fetch origin
echo "🔄 Switching to branch: $BRANCH_NAME"
git switch $BRANCH_NAME || git switch -c $BRANCH_NAME

# 4. Pull the latest version of the branch. The '|| true' part prevents errors on the very first run
#    when the remote branch doesn't exist yet.
git pull origin $BRANCH_NAME --rebase=false --allow-unrelated-histories || true

# 5. Pop the stash. This re-applies our stashed changes (your new live_inputs.csv).
echo "🍾 Applying stashed changes..."
git stash pop

# 6. Add the final version of the file.
git add live_inputs.csv

# 7. Commit only if there are actual changes.
if ! git diff-index --quiet HEAD --; then
    echo "📝 Changes detected. Committing..."
    git commit -m "Update live_inputs.csv on $(date '+%Y-%m-%d %H:%M:%S')"

    # 8. Push to the remote repository.
    echo "🚀 Pushing to origin..."
    git push -u origin $BRANCH_NAME
    echo "✅ live_inputs.csv pushed successfully!"
else
    echo "ℹ️ No changes to commit. The new data is identical to the last version."
fi