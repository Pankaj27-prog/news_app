import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/bookmark_service.dart';
import 'article_detail.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  List<Article> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    final bookmarks = await _bookmarkService.getBookmarkedArticles();
    setState(() {
      _bookmarks = bookmarks;
      _isLoading = false;
    });
  }

  Widget _buildNewsImage(String? imageUrl, {double size = 100}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: isDesktop ? 80 : 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: isDesktop ? 24 : 16),
                      Text(
                        'No bookmarked articles yet',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookmarks,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 16 : 8,
                      vertical: 8,
                    ),
                    itemCount: _bookmarks.length,
                    itemBuilder: (context, index) {
                      final article = _bookmarks[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          vertical: isDesktop ? 12 : 8,
                          horizontal: isDesktop ? 8 : 4,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArticleDetailScreen(
                                  article: article,
                                ),
                              ),
                            ).then((_) => _loadBookmarks());
                          },
                          child: Padding(
                            padding: EdgeInsets.all(isDesktop ? 16 : 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNewsImage(
                                  article.urlToImage,
                                  size: isDesktop ? 140 : 100,
                                ),
                                SizedBox(width: isDesktop ? 16 : 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.title,
                                        style: TextStyle(
                                          fontSize: isDesktop ? 18 : 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: isDesktop ? 12 : 8),
                                      Text(
                                        article.description,
                                        style: TextStyle(
                                          fontSize: isDesktop ? 16 : 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: isDesktop ? 12 : 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.source,
                                            size: isDesktop ? 16 : 14,
                                            color: Colors.grey[500],
                                          ),
                                          SizedBox(width: isDesktop ? 6 : 4),
                                          Text(
                                            article.source,
                                            style: TextStyle(
                                              fontSize: isDesktop ? 14 : 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
} 