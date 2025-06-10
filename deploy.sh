#!/bin/bash

# Install Flutter dependencies
flutter pub get

# Build the Flutter web app
flutter build web

# Install Node.js dependencies
npm install

# Start the server
npm start 