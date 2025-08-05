#!/bin/bash
cd .  # wherever your Render repo is cloned
git pull
cp /live_inputs.csv ./drift-data/live_inputs.csv
git add ./drift-data/live_inputs.csv
git commit -m "Sync live inputs: $(date +'%Y-%m-%d %H:%M:%S')"
git push https://$RENDER_GITHUB_TOKEN@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git