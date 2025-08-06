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

# Define variables
BRANCH_NAME="live-data-branch"
REPO_URL="https://$GITHUB_PAT@github.com/MyMLOpsProjects/20_Model_CI-CD_using_Render_DataInference.git"

# Initialize git if not already a repo
if [ ! -d .git ]; then
    echo "🤔 .git directory not found. Initializing a new repository..."
    git init

    # Set Git identity BEFORE first commit
    git config user.email "pycsrbypankaj@gmail.com"
    git config user.name "pycsr"

    git remote add origin $REPO_URL

    # Create an empty initial commit to enable stash
    git commit --allow-empty -m "Initial commit for CI environment setup"
fi

# Ensure Git identity is set in case repo already existed
git config user.email "pycsrbypankaj@gmail.com"
git config user.name "pycsr"

# Clean merge markers from existing file, if present
if [ -f live_inputs.csv ]; then
    echo "🧹 Cleaning merge markers from live_inputs.csv (if any)..."
    # Remove any lines containing merge conflict markers, regardless of position
    sed -i '/<<<<<<<\|=======\|>>>>>>>/d' live_inputs.csv
else
    echo "📄 live_inputs.csv not found. Creating a new file with headers."
    echo "sepal_length,sepal_width,petal_length,petal_width" > live_inputs.csv
fi


# Append the new row
echo "➕ Appending new input row: $INPUT_ROW"
echo "$INPUT_ROW" >> live_inputs.csv

# Stage the CSV file
git add live_inputs.csv

# Check if initial commit exists, then stash
if git rev-parse --verify HEAD > /dev/null 2>&1; then
    echo "🗄️ Stashing new live_inputs.csv to switch branches safely."
    git stash
else
    echo "⚠️ No commits found yet. Skipping stash."
fi

# Fetch latest remote refs
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

# Apply stashed changes (if any)
echo "🍾 Applying stashed changes..."
git stash pop || echo "ℹ️ Nothing to pop from stash."

# Stage final version of the CSV
git add live_inputs.csv

# Commit only if there are actual changes
if ! git diff-index --quiet HEAD --; then
    echo "📝 Changes detected. Committing..."
    git commit -m "Update live_inputs.csv on $(date '+%Y-%m-%d %H:%M:%S')"

    # Push to remote branch
    echo "🚀 Pushing to origin..."
    git push -u origin $BRANCH_NAME
    echo "✅ live_inputs.csv pushed successfully!"
else
    echo "ℹ️ No changes to commit. The new data is identical to the last version."
fi
