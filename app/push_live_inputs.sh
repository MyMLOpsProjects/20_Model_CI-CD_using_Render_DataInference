#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "📂 Current directory: $(pwd)"

# Navigate to Render working directory if needed
# cd /opt/render/project/src || exit

# Check if the data file exists before doing anything
if [ ! -f live_inputs.csv ]; then
    echo "❌ live_inputs.csv not found. Skipping Git operations."
    exit 0
fi

# 1. Initialize git if not already a repo
if [ ! -d .git ]; then
    git init
    git remote add origin https://$GITHUB_PAT@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git
fi

# 2. Set Git identity
git config user.email "pycsrbypankaj@gmail.com"
git config user.name "pycsr"

# 3. Fetch the latest state from the remote repository
git fetch origin

# 4. Use 'git switch' to safely get on the branch
# 'git switch -c' creates the branch if it doesn't exist locally but exists on remote.
# If it doesn't exist on remote either, it creates an orphan branch.
BRANCH_NAME="live-data-branch"
if git show-ref --verify --quiet refs/remotes/origin/$BRANCH_NAME; then
    # Branch exists on remote, check it out
    git switch $BRANCH_NAME
else
    # Branch does not exist on remote, create an orphan branch
    git switch --orphan $BRANCH_NAME
fi

# 5. Set pull strategy and pull latest changes (if any)
# This ensures we have the latest history before we commit our changes.
git config pull.rebase false
git pull origin $BRANCH_NAME --allow-unrelated-histories || true # Use '|| true' to ignore errors on first push

# 6. Add your live data file
git add live_inputs.csv

# 7. Commit only if there are changes
if ! git diff-index --quiet HEAD --; then
    echo "📝 Changes detected. Committing..."
    git commit -m "Update live_inputs.csv on $(date '+%Y-%m-%d %H:%M:%S')"

    # 8. Push to remote
    # The -u flag sets the upstream for the first push
    echo "🚀 Pushing to origin..."
    if git push -u origin $BRANCH_NAME; then
        echo "✅ live_inputs.csv pushed successfully"
    else
        echo "⚠️ Push failed — trying force push"
        git push -u origin $BRANCH_NAME --force
    fi
else
    echo "ℹ️ No changes to commit. Working directory is clean."
fi