# #!/bin/bash
# echo "Current directory is: $(pwd)"
# # cd ./app || exit
# # or
# # cd /opt/render/project/src || exit # Commonly used dir by render

# # 2. Initialize git if not already a repo
# if [ ! -d .git ]; then
#     git init
#     git remote add origin https://$GITHUB_PAT@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git
# fi

# # 3. Set Git identity (for committing)
# git config user.email "pycsrbypankaj@gmail.com"
# git config user.name "pycsr"

# # 4. Create a temp branch if in detached HEAD state
# git checkout -B live-data-branch

# # 5. Pull the latest (optional: handle merge conflicts carefully)
# git pull origin live-data-branch --allow-unrelated-histories

# # 6. Add your live data file
# git add live_inputs.csv

# # 7. Commit only if there are changes
# if ! git diff-index --quiet HEAD --; then
#     git commit -m "Update live_inputs.csv"
#     git push origin live-data-branch
#     echo "✅ live_inputs.csv pushed"
# else
#     echo "ℹ️ No changes to commit"
# fi

#!/bin/bash
echo "📂 Current directory is: $(pwd)"

# 1. Navigate to project directory if needed
# cd /opt/render/project/src/app || exit

# 2. Initialize git if not already a repo
if [ ! -d .git ]; then
    git init
    git remote add origin https://$GITHUB_PAT@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git
    git fetch origin
    git checkout -b main || git checkout main
else
    git checkout main || git checkout -b main
fi

# 3. Set Git identity
git config user.email "pycsrbypankaj@gmail.com"
git config user.name "pycsr"

# 4. Pull latest changes from main branch (optional, safe merge)
git pull origin main --allow-unrelated-histories

# 5. Add your live data file
git add live_inputs.csv

# 6. Commit only if changes exist
if ! git diff-index --quiet HEAD --; then
    git commit -m "Update live_inputs.csv"
    git push origin main
    echo "✅ live_inputs.csv pushed to main"
else
    echo "ℹ️ No changes to commit"
fi
