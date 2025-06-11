const express = require('express');
const path = require('path');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Enable CORS
app.use(cors());

// Serve static files from the build directory
app.use(express.static(path.join(__dirname, 'build/web')));

// Proxy endpoint for news API
app.get('/api/news', async (req, res) => {
  try {
    const { category, searchQuery } = req.query;
    let url = 'https://newsapi.org/v2/';
    
    if (searchQuery) {
      url += `everything?q=${searchQuery}`;
    } else if (category && category !== 'All') {
      url += `top-headlines?category=${category.toLowerCase()}`;
    } else {
      url += 'top-headlines?country=us';
    }
    
    const apiKey = process.env.NEWS_API_KEY;
    if (!apiKey) {
      throw new Error('NEWS_API_KEY is not configured');
    }
    
    url += `&apiKey=${apiKey}&language=en&pageSize=50`;
    console.log('Making request to News API:', url.replace(apiKey, 'REDACTED'));
    
    const response = await axios.get(url);
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching news:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: 'Failed to fetch news',
      details: error.response?.data || error.message
    });
  }
});

// Handle all other routes by serving the index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web', 'index.html'));
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
  console.log('NEWS_API_KEY configured:', process.env.NEWS_API_KEY ? 'Yes' : 'No');
}); 