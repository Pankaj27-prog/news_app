import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SummaryService {
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 1);

  String _generateFallbackSummary(String content) {
    if (content.isEmpty) return 'No content available for summary.';
    
    // Clean the content by removing extra whitespace and newlines
    content = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Split into sentences and filter out very short ones
    final sentences = content.split(RegExp(r'[.!?]'))
        .where((s) => s.trim().length > 20)
        .map((s) => s.trim())
        .toList();
    
    if (sentences.isEmpty) {
      // If no good sentences found, take first 200 characters
      return '${content.substring(0, content.length.clamp(0, 200))}...';
    }
    
    // Take first 2-3 sentences
    final summarySentences = sentences.take(3).join('. ');
    return '$summarySentences...';
  }

  Future<String> _tryOpenAISummary(String content, int retryCount) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that summarizes news articles. Provide a concise TL;DR summary in 2-3 sentences.'
            },
            {
              'role': 'user',
              'content': 'Please summarize this article: $content'
            }
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && 
            data['choices'].isNotEmpty && 
            data['choices'][0]['message'] != null) {
          return data['choices'][0]['message']['content'].trim();
        }
      }
      
      // If we get here, the API call failed
      if (retryCount < _maxRetries) {
        await Future.delayed(_retryDelay);
        return _tryOpenAISummary(content, retryCount + 1);
      }
      
      return _generateFallbackSummary(content);
    } catch (e) {
      if (retryCount < _maxRetries) {
        await Future.delayed(_retryDelay);
        return _tryOpenAISummary(content, retryCount + 1);
      }
      return _generateFallbackSummary(content);
    }
  }

  Future<String> getArticleSummary(String content) async {
    if (content.isEmpty) {
      return 'No content available for summary.';
    }

    try {
      return await _tryOpenAISummary(content, 0);
    } catch (e) {
      // Only print critical errors that need attention
      if (e is http.ClientException || e is FormatException) {
        debugPrint('Critical error in summary generation: $e');
      }
      return _generateFallbackSummary(content);
    }
  }
}