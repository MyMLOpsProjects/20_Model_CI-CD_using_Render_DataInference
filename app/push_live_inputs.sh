#!/bin/bash

cd /opt/render/project/src/app
echo "📂 Current directory: $(pwd)"

# Init git only if needed
if [ ! -d .git ]; then
    git init
    git remote add origin https://$GITHUB_PAT@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git
fi

git config user.email "pycsrbypankaj@gmail.com"
git config user.name "pycsr"

# Checkout branch
git checkout -B live-data-branch

# ✅ Fetch latest version of live_inputs.csv directly from GitHub
curl -s -o live_inputs.csv https://raw.githubusercontent.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference/live-data-branch/live_inputs.csv || touch live_inputs.csv

# Now append is done via Python (this script doesn't touch the data itself)

# Add, commit, push
git add live_inputs.csv
if ! git diff-index --quiet HEAD --; then
    git commit -m "Append to live_inputs.csv on $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin live-data-branch || git push origin live-data-branch --force
    echo "✅ live_inputs.csv pushed"
else
    echo "ℹ️ No new changes to commit"
fi
