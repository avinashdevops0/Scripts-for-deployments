#!/bin/bash

#====================== Project Configuration ==========================
PROJECT_NAME=""                         # Name of your project
PORT=                                   # Port to run your backend app

#----------- GitHub details required for Deployment --------------------
GITHUB_USERNAME=""
GITHUB_TOKEN=""
GITHUB_REPOSITORY=""
CLONED_REPO_NAME=""
GITHUB_BRANCH=""

#---------------------- Deployment Directory ---------------------------
DEPLOY_PATH="/opt/node-applications/codedeploy-apps/$PROJECT_NAME"
#=======================================================================

set -e  # Exit on error

echo "============================================="
echo "🚀 Starting first-time deployment for $PROJECT_NAME"
echo "============================================="

# Step 1: Kill any existing process
echo "🔍 Checking for existing process on port $PORT..."
PID=$(lsof -t -i:$PORT)

if [ -n "$PID" ]; then
  echo "⚠️  Terminating process $PID..."
  kill -9 "$PID"
  echo "✅ Process terminated."
else
  echo "✅ No process on port $PORT."
fi
# Prepare deployment directory
if [ -d "/opt/node-applications/codedeploy-apps/$PROJECT_NAME" ]; then
  echo "🗑️ Directory '/opt/node-applications/codedeploy-apps/$PROJECT_NAME' already exists. Removing..."
  rm -rf "/opt/node-applications/codedeploy-apps/$PROJECT_NAME"
else
  echo "📁 Creating directory '/opt/node-applications/codedeploy-apps/$PROJECT_NAME'..."
fi

mkdir -p "/opt/node-applications/codedeploy-apps/$PROJECT_NAME"

# Step 2: Remove old repo
echo "🧹 Removing old repository..."
rm -rf /root/$CLONED_REPO_NAME

# Step 3: Clone latest code
echo "📥 Cloning repository..."
git clone "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

# Step 4: Checkout branch
cd /root/$CLONED_REPO_NAME
git checkout $GITHUB_BRANCH

# Step 5: Clean deployment directory
rm -rf "$DEPLOY_PATH"

# Step 6: Create deployment directory
mkdir -p "$DEPLOY_PATH"

# Step 7: Copy project files
cp -r * "$DEPLOY_PATH"
cp -r .[^.]* "$DEPLOY_PATH" 2>/dev/null || true

# Step 8: Install dependencies
cd "$DEPLOY_PATH"
npm install

# Step 9: Start backend
npm start &>> "$PROJECT_NAME.log" &

# Step 10: Check process
sleep 5
NEW_PID=$(lsof -t -i:$PORT)
if [ -n "$NEW_PID" ]; then
  echo "✅ Backend running on port $PORT (PID: $NEW_PID)."
else
  echo "❌ Backend failed to start. Check logs."
fi

echo "============================================="
echo "✅ $PROJECT_NAME deployment completed"
echo "============================================="
