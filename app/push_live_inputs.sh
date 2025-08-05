#!/bin/bash
cd .  # wherever your Render repo is cloned
git pull origin main
git add live_inputs.csv

# Only commit if there are changes
if ! git diff-index --quiet HEAD --; then
    git commit -m "Updated live inputs"
    git push https://$RENDER_GITHUB_TOKEN@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git
    echo "✅ live_inputs.csv pushed to GitHub"
else
    echo "ℹ️ No changes to commit"
fi

# git commit -m "Update live inputs"
# git push origin main
# cp /live_inputs.csv ./drift-data/live_inputs.csv
# git add ./drift-data/live_inputs.csv
# git commit -m "Sync live inputs: $(date +'%Y-%m-%d %H:%M:%S')"
# git push https://$RENDER_GITHUB_TOKEN@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git