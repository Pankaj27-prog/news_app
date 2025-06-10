#!/bin/bash

# Build Flutter web
echo "Building Flutter web..."
flutter build web

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
npm install

# Start the server
echo "Starting server..."
node server.js 