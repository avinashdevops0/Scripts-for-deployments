#!/bin/bash

#====================== Project Configuration ==========================
PROJECT_NAME=                   # Name of your project
PORT=                           # Port to run your application

#----------- GitHub details required for Deployment -------------------
GITHUB_USERNAME=                # GitHub username (Ex: Avinash001)
GITHUB_ACCESSTOKEN=             # GitHub access token (Ex: QEFUVIUFWERGVBJJertgv3456)
GITHUB_REPOSITORY=              # GitHub repository (Ex: avinash001/demoapplication)
CLONED_REPO_NAME=               # Name of repo folder after cloning (Ex: demoapplication)
GITHUB_Remote_BRANCH_NAME=      # Branch to deploy (Ex: main)

#------------------------ Deployment Directory -------------------------
Deployment_DIR_Name=            # Directory name under /var/www/html/
#=======================================================================

echo "============================================="
echo "🚀 Starting deployment process for $PROJECT_NAME"
echo "============================================="

# Kill any process running on the specified port
echo "🔍 Checking if any process is running on port $PORT..."
PID=$(lsof -t -i:$PORT)

if [ -n "$PID" ]; then
  echo "⚠️  Process found on port $PORT (PID: $PID). Terminating it..."
  kill -9 $PID
  echo "✅ Process (PID: $PID) has been terminated."
else
  echo "✅ No process is currently running on port $PORT."
fi

# Prepare deployment directory
if [ -d "/var/www/html/$Deployment_DIR_Name" ]; then
  echo "🗑️ Directory '/var/www/html/$Deployment_DIR_Name' already exists. Removing..."
  rm -rf "/var/www/html/$Deployment_DIR_Name"
else
  echo "📁 Creating directory '/var/www/html/$Deployment_DIR_Name'..."
fi

mkdir -p "/var/www/html/$Deployment_DIR_Name"

# Clone repository
echo "📥 Cloning repository..."
git clone "https://${GITHUB_USERNAME}:${GITHUB_ACCESSTOKEN}@github.com/${GITHUB_REPOSITORY}.git"

# Checkout specified branch
cd "$CLONED_REPO_NAME" || { echo "❌ Failed to access cloned directory"; exit 1; }
git checkout "$GITHUB_Remote_BRANCH_NAME"

# Move build files to deployment directory
if [ -d "build" ]; then
  echo "📦 Moving build files to deployment directory..."
  mv build/* "/var/www/html/$Deployment_DIR_Name"
  echo "✅ Files moved successfully"
else
  echo "❌ Build directory not found. Make sure the project is built before deploying."
  exit 1
fi

# Serve the frontend
echo "🚀 Starting frontend server on port $PORT..."
cd /var/www/html
serve -s "$Deployment_DIR_Name" -l "$PORT" &>> "$Deployment_DIR_Name.log" &

# Wait and check
echo "⏳ Waiting for the frontend to start..."
sleep 5
NEW_PID=$(lsof -t -i:$PORT)

if [ -n "$NEW_PID" ]; then
  echo "✅ Frontend is live on port $PORT (PID: $NEW_PID)."
else
  echo "❌ Frontend failed to start. Please check '$Deployment_DIR_Name.log' for details."
fi

echo "============================================="
echo "✅ $PROJECT_NAME deployment completed"
echo "============================================="
