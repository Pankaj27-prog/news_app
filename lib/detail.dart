// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../services/bookmark_service.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> article;
  const DetailPage({super.key, required this.article});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final BookmarkService _bookmarkService = BookmarkService();
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    try {
      final article = Article.fromJson(widget.article);
      final isBookmarked = await _bookmarkService.isArticleBookmarked(article);
      if (mounted) {
        setState(() {
          this.isBookmarked = isBookmarked;
        });
      }
    } catch (e) {
      // Silent error handling for bookmark status
    }
  }

  Future<void> _toggleBookmark() async {
    try {
      final article = Article.fromJson(widget.article);
      await _bookmarkService.toggleBookmark(article);
      if (mounted) {
        setState(() {
          isBookmarked = !isBookmarked;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update bookmark'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      appBar: AppBar(
        title: Text(article['source']['name'] ?? 'News'),
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Placeholder: You can integrate `share_plus` later
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
