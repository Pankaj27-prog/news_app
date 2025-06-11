// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../models/article.dart';
// import '../services/bookmark_service.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> article;
  const DetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['source']['name'] ?? 'News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Share coming soon")),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (article['urlToImage'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                article['urlToImage'],
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            article['title'] ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            article['content'] ?? 'No content available.',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
