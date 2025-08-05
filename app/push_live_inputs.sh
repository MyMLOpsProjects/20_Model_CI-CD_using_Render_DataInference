#!/bin/bash
echo "📂 Current directory: $(pwd)"

# 1. Init repo if not already
if [ ! -d .git ]; then
    git init
    git remote add origin https://$GITHUB_PAT@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git
fi

# 2. Set identity
git config user.email "pycsrbypankaj@gmail.com"
git config user.name "pycsr"
git config pull.rebase false

# 3. Checkout branch
git checkout -B live-data-branch

# 4. Pull latest to ensure no loss
git pull origin live-data-branch --allow-unrelated-histories

# 5. Make sure file exists
if [ -f live_inputs.csv ]; then
    git add live_inputs.csv

    if ! git diff-index --quiet HEAD --; then
        git commit -m "Append to live_inputs.csv on $(date '+%Y-%m-%d %H:%M:%S')"
        git push origin live-data-branch || git push origin live-data-branch --force
        echo "✅ live_inputs.csv pushed"
    else
        echo "ℹ️ No changes to commit"
    fi
else
    echo "❌ live_inputs.csv not found"
fi
