import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Map<String, dynamic>> bookmarks = [];

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList('bookmarks') ?? [];
    setState(() {
      bookmarks = saved
          .map((jsonString) => jsonDecode(jsonString) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Bookmarks', )),
      body: bookmarks.isEmpty
          ? const Center(child: Text('No bookmarked articles yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final article = bookmarks[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(article: article),
                    ),
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article['urlToImage'] != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              article['urlToImage'],
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['title'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                article['description'] ?? '',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
