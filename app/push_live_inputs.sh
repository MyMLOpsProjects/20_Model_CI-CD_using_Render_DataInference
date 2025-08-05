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
    git init
    git remote add origin https://$GITHUB_PAT@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git
fi

# Set Git identity for the commit
git config user.email "pycsrbypankaj@gmail.com"
git config user.name "pycsr"

# --- The Stash Workflow ---

# 1. Add the new/modified live_inputs.csv to the staging area.
git add live_inputs.csv

# 2. Stash the staged changes. This "hides" the file and cleans the working directory.
#    This allows us to switch branches without any errors.
echo "🗄️ Stashing new live_inputs.csv to switch branches safely."
git stash

# 3. Now that the directory is clean, fetch remote state and switch branches.
BRANCH_NAME="live-data-branch"
git fetch origin
echo "🔄 Switching to branch: $BRANCH_NAME"
# Switch to the branch. Use '|| git switch -c' as a fallback to create it if it doesn't exist.
git switch $BRANCH_NAME || git switch -c $BRANCH_NAME

# 4. Pull the latest version of the branch to get its history.
#    This step is optional if only one process ever writes to this branch, but it's good practice.
git pull origin $BRANCH_NAME --rebase=false --allow-unrelated-histories

# 5. Pop the stash. This re-applies our stashed changes.
#    Your NEW live_inputs.csv will now overwrite the old one from the pull. This is what we want.
echo "🍾 Applying stashed changes..."
git stash pop

# --- End of Stash Workflow ---

# 6. Add the final version of the file again just in case the pop unstaged it.
git add live_inputs.csv

# 7. Commit only if there are actual changes.
if ! git diff-index --quiet HEAD --; then
    echo "📝 Changes detected. Committing..."
    git commit -m "Update live_inputs.csv on $(date '+%Y-%m-%d %H:%M:%S')"

    # 8. Push to the remote repository.
    echo "🚀 Pushing to origin..."
    # The -u flag sets the upstream for the first push.
    git push -u origin $BRANCH_NAME
    echo "✅ live_inputs.csv pushed successfully!"
else
    echo "ℹ️ No changes to commit. The new data is identical to the last version."
fi