#!/bin/bash
echo "📂 Current directory: $(pwd)"

# Navigate to Render working directory if needed
# cd /opt/render/project/src || exit

# 1. Initialize git if not already a repo
if [ ! -d .git ]; then
    git init
    git remote add origin https://$GITHUB_PAT@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git
fi

# 2. Set Git identity
git config user.email "pycsrbypankaj@gmail.com"
git config user.name "pycsr"

# 3. Checkout or create the live-data-branch
git checkout -B live-data-branch

# 4. Set pull strategy to merge to avoid divergence errors
git config pull.rebase false

# 5. Pull remote changes first (merge strategy)
git pull origin live-data-branch --allow-unrelated-histories

# 6. Add your live data file
if [ -f live_inputs.csv ]; then
    git add live_inputs.csv

    # 7. Commit only if there are changes
    if ! git diff-index --quiet HEAD --; then
        git commit -m "Update live_inputs.csv on $(date '+%Y-%m-%d %H:%M:%S')"

        # 8. Push to remote
        if git push origin live-data-branch; then
            echo "✅ live_inputs.csv pushed successfully"
        else
            echo "⚠️ Push failed — trying force push"
            git push origin live-data-branch --force
        fi
    else
        echo "ℹ️ No changes to commit"
    fi
else
    echo "❌ live_inputs.csv not found. Skipping Git operations."
fi
