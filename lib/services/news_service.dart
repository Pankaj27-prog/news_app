import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:js/js.dart';
import 'dart:html' as html;

@JS('window.env')
external dynamic get _windowEnv;

class NewsService {
  // Use relative URL to hit our proxy server
  static const String _baseUrl = '/api/news';
  
  // API Key Configuration
  static String get _apiKey {
    if (kIsWeb) {
      // For web, try to get the API key from window.env
      try {
        // Access window.env directly
        final apiKey = const String.fromEnvironment('NEWS_API_KEY');
        if (apiKey.isNotEmpty) {
          debugPrint('Using API key from build environment');
          return apiKey;
        }
      } catch (e) {
        debugPrint('Error getting API key from build environment: $e');
      }
    }
    
    // Fallback to dotenv
    final key = dotenv.env['NEWS_API_KEY'];
    if (key == null || key.isEmpty) {
      debugPrint('Warning: NEWS_API_KEY not found in environment variables');
      debugPrint('Current environment variables: ${dotenv.env.toString()}');
      return '';
    }
    return key;
  }

  // Fallback image URL
  static const String _fallbackImageUrl = 'https://via.placeholder.com/200x200?text=News';

  // Process image URL to handle CORS issues
  static String processImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return _fallbackImageUrl;
    }
    
    // If the image URL is from picsum.photos, use a different service
    if (url.contains('picsum.photos')) {
      return _fallbackImageUrl;
    }
    
    return url;
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
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['searchQuery'] = searchQuery;
      } else if (category != null && category != 'All') {
        queryParams['category'] = category;
      }

      // Build URL with query parameters
      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      debugPrint('Making request to proxy server: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          final articles = List<Map<String, dynamic>>.from(data['articles']);
          if (articles.isNotEmpty) {
            return articles;
          }
        }
      }
      
      debugPrint('API Error: ${response.statusCode} - ${response.body}');
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