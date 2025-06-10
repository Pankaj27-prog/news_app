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

// Debug: Log current directory and public directory contents
console.log('Current directory:', __dirname);
const publicDir = path.join(__dirname, 'public');
console.log('Public directory:', publicDir);

// Ensure public directory exists
async function ensurePublicDirectory() {
  try {
    // Create public directory if it doesn't exist
    await fs.ensureDir(publicDir);
    console.log('Public directory created/verified');

    // Create index.html if it doesn't exist
    const indexPath = path.join(publicDir, 'index.html');
    if (!await fs.pathExists(indexPath)) {
      const basicHtml = `<!DOCTYPE html>
<html>
<head>
    <title>News App</title>
    <base href="/">
</head>
<body>
    <script src="main.dart.js"></script>
</body>
</html>`;
      await fs.writeFile(indexPath, basicHtml);
      console.log('Created index.html');
    }

    // List contents of public directory
    const files = await fs.readdir(publicDir);
    console.log('Public directory contents:', files);
  } catch (error) {
    console.error('Error setting up public directory:', error);
    process.exit(1);
  }
}

// Initialize public directory
ensurePublicDirectory().then(() => {
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

  // Serve static files from the public directory
  app.use(express.static(publicDir, {
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
    const indexPath = path.join(publicDir, 'index.html');
    console.log('Serving index.html from:', indexPath);
    res.sendFile(indexPath);
  });

  app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
  });
}); 