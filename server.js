const express = require('express');
const path = require('path');
const fs = require('fs-extra');
const compression = require('compression');
const helmet = require('helmet');
const app = express();
const port = process.env.PORT || 3000;

// Enable security headers
app.use(helmet({
  contentSecurityPolicy: false, // Disable CSP for Flutter web
  crossOriginEmbedderPolicy: false, // Disable COEP for Flutter web
  crossOriginOpenerPolicy: false, // Disable COOP for Flutter web
  crossOriginResourcePolicy: false // Disable CORP for Flutter web
}));

// Enable compression
app.use(compression());

// Debug: Log current directory and build directory contents
console.log('Current directory:', __dirname);
const buildDir = path.join(__dirname, 'build', 'web');
console.log('Build directory:', buildDir);

// Ensure build directory exists
async function ensureBuildDirectory() {
  try {
    // Check if build directory exists
    if (!await fs.pathExists(buildDir)) {
      console.error('Build directory not found. Please run "flutter build web" first.');
      process.exit(1);
    }

    // List contents of build directory
    const files = await fs.readdir(buildDir);
    console.log('Build directory contents:', files);
  } catch (error) {
    console.error('Error checking build directory:', error);
    process.exit(1);
  }
}

// Initialize build directory check
ensureBuildDirectory().then(() => {
  // Set proper MIME types
  app.use((req, res, next) => {
    if (req.url.endsWith('.js')) {
      res.type('application/javascript');
    } else if (req.url.endsWith('.css')) {
      res.type('text/css');
    } else if (req.url.endsWith('.html')) {
      res.type('text/html');
    } else if (req.url.endsWith('.json')) {
      res.type('application/json');
    } else if (req.url.endsWith('.wasm')) {
      res.type('application/wasm');
    }
    next();
  });

  // Serve static files from the build directory
  app.use(express.static(buildDir, {
    maxAge: '1h',
    etag: true,
    lastModified: true,
    setHeaders: (res, path) => {
      if (path.endsWith('.js')) {
        res.setHeader('Content-Type', 'application/javascript');
      }
    }
  }));

  // Handle all routes by serving index.html
  app.get('*', (req, res) => {
    const indexPath = path.join(buildDir, 'index.html');
    console.log('Serving index.html from:', indexPath);
    res.sendFile(indexPath);
  });

  app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
  });
}); 