const express = require('express');
const path = require('path');
const axios = require('axios');
const app = express();
const port = process.env.PORT || 3000;

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
    
    url += `&apiKey=${process.env.NEWS_API_KEY}&language=en&pageSize=50`;
    
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
}); 