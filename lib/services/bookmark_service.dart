import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class BookmarkService {
  static const String _bookmarksKey = 'bookmarked_articles';

  Future<List<Article>> getBookmarkedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
    
    return bookmarksJson
        .map((json) => Article.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<bool> isArticleBookmarked(Article article) async {
    final bookmarks = await getBookmarkedArticles();
    return bookmarks.any((bookmark) => bookmark.url == article.url);
  }

  Future<void> toggleBookmark(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
    
    if (await isArticleBookmarked(article)) {
      // Remove bookmark
      bookmarksJson.removeWhere((json) {
        final bookmark = Article.fromJson(jsonDecode(json));
        return bookmark.url == article.url;
      });
    } else {
      // Add bookmark
      bookmarksJson.add(jsonEncode(article.toJson()));
    }
    
    await prefs.setStringList(_bookmarksKey, bookmarksJson);
  }
} 