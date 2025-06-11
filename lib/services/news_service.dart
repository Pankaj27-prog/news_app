import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  
  // API Key Configuration
  static String get _apiKey {
    final key = dotenv.env['NEWS_API_KEY'];
    if (key == null || key.isEmpty) {
      debugPrint('Warning: NEWS_API_KEY not found in environment variables');
      return '';
    }
    return key;
  }
  
  // Fallback data for testing and when API is unavailable
  static final List<Map<String, dynamic>> _fallbackArticles = [
    {
      'title': 'Breaking: Major Tech Innovation',
      'description': 'A revolutionary breakthrough in technology promises to change how we interact with digital devices.',
      'urlToImage': 'https://picsum.photos/seed/tech/200',
      'source': {'name': 'Tech Daily'},
      'publishedAt': DateTime.now().toIso8601String(),
    },
    {
      'title': 'Sports: Championship Finals',
      'description': 'In an exciting match, the underdogs have secured their place in the finals.',
      'urlToImage': 'https://picsum.photos/seed/sports/200',
      'source': {'name': 'Sports Central'},
      'publishedAt': DateTime.now().toIso8601String(),
    },
    {
      'title': 'Business: Market Update',
      'description': 'Global markets show positive trends as new economic policies take effect.',
      'urlToImage': 'https://picsum.photos/seed/business/200',
      'source': {'name': 'Business Times'},
      'publishedAt': DateTime.now().toIso8601String(),
    },
    {
      'title': 'Entertainment: Award Ceremony',
      'description': 'Stars gather for the annual entertainment awards ceremony.',
      'urlToImage': 'https://picsum.photos/seed/entertainment/200',
      'source': {'name': 'Entertainment Weekly'},
      'publishedAt': DateTime.now().toIso8601String(),
    },
    {
      'title': 'Health: Medical Breakthrough',
      'description': 'Scientists announce promising results in medical research.',
      'urlToImage': 'https://picsum.photos/seed/health/200',
      'source': {'name': 'Health News'},
      'publishedAt': DateTime.now().toIso8601String(),
    },
  ];

  Future<List<Map<String, dynamic>>> getNews({
    String? category,
    String? searchQuery,
  }) async {
    if (_apiKey.isEmpty) {
      debugPrint('Error: API key not configured');
      throw Exception('News API key not configured. Please check your environment variables.');
    }

    String url;
    try {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url = '$_baseUrl/everything?q=$searchQuery&apiKey=$_apiKey&language=en&sortBy=publishedAt';
      } else if (category != null && category != 'All') {
        url = '$_baseUrl/top-headlines?category=${category.toLowerCase()}&apiKey=$_apiKey&language=en&country=us&pageSize=50';
      } else {
        url = '$_baseUrl/top-headlines?country=us&apiKey=$_apiKey&language=en&pageSize=50';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          final articles = List<Map<String, dynamic>>.from(data['articles']);
          if (articles.isNotEmpty) {
            return articles;
          }
        }
      }
      
      throw Exception('Failed to fetch news: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching news: $e');
      throw Exception('Failed to fetch news. Please try again later.');
    }
  }

  List<Map<String, dynamic>> _getFilteredFallbackData(String? category, String? searchQuery) {
    if (searchQuery != null && searchQuery.isNotEmpty) {
      return _fallbackArticles.where((article) {
        final title = article['title'].toString().toLowerCase();
        final description = article['description'].toString().toLowerCase();
        final query = searchQuery.toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    if (category != null && category != 'All') {
      return _fallbackArticles.where((article) {
        final title = article['title'].toString().toLowerCase();
        final description = article['description'].toString().toLowerCase();
        final categoryLower = category.toLowerCase();
        return title.contains(categoryLower) || description.contains(categoryLower);
      }).toList();
    }

    return _fallbackArticles;
  }
} 