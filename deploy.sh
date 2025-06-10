#!/bin/bash

# Exit on error
set -e

# Install Flutter
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify Flutter installation
echo "Verifying Flutter installation..."
flutter doctor

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build Flutter web app
echo "Building Flutter web app..."
flutter build web --release

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
npm install

echo "Build completed successfully!"

# Start the server
echo "Starting server..."
node server.js 