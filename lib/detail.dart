import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final Map article;
  const DetailPage({super.key, required this.article});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    checkIfBookmarked();
  }

  Future<void> checkIfBookmarked() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved =
        prefs.getStringList('bookmarks') ?? <String>[];
    final currentJson = jsonEncode(widget.article);
    setState(() {
      isBookmarked = saved.contains(currentJson);
    });
  }

  Future<void> toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved =
        prefs.getStringList('bookmarks') ?? <String>[];
    final currentJson = jsonEncode(widget.article);

    if (isBookmarked) {
      saved.remove(currentJson);
    } else {
      saved.add(currentJson);
    }

    await prefs.setStringList('bookmarks', saved);
    setState(() => isBookmarked = !isBookmarked);
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
            onPressed: toggleBookmark,
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
