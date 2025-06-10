//import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//import 'detail.dart';
// import 'bookmarks.dart';
import 'services/news_service.dart';
import 'models/article.dart';
import 'screens/article_detail.dart';
import 'screens/bookmarks_screen.dart';
import 'services/bookmark_service.dart';
import 'services/quiz_service.dart';
import 'widgets/quiz_dialog.dart';


class DashboardPage extends StatefulWidget {
  final String title;
  const DashboardPage({super.key, required this.title});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final NewsService _newsService = NewsService();
  final BookmarkService _bookmarkService = BookmarkService();
  final QuizService _quizService = QuizService();
  final List<String> _categories = [
    'All',
    'Technology',
    'Business',
    'Sports',
    'Entertainment',
    'Health',
    'Science'
  ];
  
  List<Article> _articles = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadNews();
    _checkAndShowQuiz();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNews({String? searchQuery}) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final articles = await _newsService.getNews(
        category: _categories[_tabController.index],
        searchQuery: searchQuery,
      );
      if (!mounted) return;
      setState(() {
        _articles = articles.map((json) => Article.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndShowQuiz() async {
    if (_articles.isEmpty) return;

    if (await _quizService.shouldShowNewQuiz()) {
      // Generate quiz from a random article
      final randomArticle = _articles[DateTime.now().millisecondsSinceEpoch % _articles.length];
      await _quizService.generateQuiz(randomArticle, _articles);
    }
    
    if (mounted) {
      final quizData = await _quizService.getCurrentQuiz();
      // Only show quiz if we have valid data
      if (quizData['question']?.isNotEmpty ?? false) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => QuizDialog(quizData: quizData),
        );
      }
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _loadNews(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsImage(String? imageUrl, {double size = 100}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.newspaper,
          size: size * 0.4,
          color: Colors.grey[400],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.newspaper,
              size: size * 0.4,
              color: Colors.grey[400],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(Article article, bool isDesktop) {
    return Card(
      margin: EdgeInsets.all(isDesktop ? 12.0 : 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(article: article),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 16.0 : 12.0),
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
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.source,
                                size: isDesktop ? 16 : 14,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: isDesktop ? 6 : 4),
                              Expanded(
                                child: Text(
                                  article.source,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 14 : 12,
                                    color: Colors.grey[500],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder<bool>(
                          future: _bookmarkService.isArticleBookmarked(article),
                          builder: (context, snapshot) {
                            final isBookmarked = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: isBookmarked ? Theme.of(context).colorScheme.primary : null,
                                size: isDesktop ? 28 : 24,
                              ),
                              onPressed: () async {
                                await _bookmarkService.toggleBookmark(article);
                                setState(() {}); // Refresh the UI
                              },
                            );
                          },
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
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) => _loadNews(),
          tabs: _categories.map((category) => Tab(text: category)).toList(),
          labelStyle: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: () async {
              if (_articles.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please wait for articles to load'),
                  ),
                );
                return;
              }
              
              // Generate new quiz from random article
              final randomArticle = _articles[DateTime.now().millisecondsSinceEpoch % _articles.length];
              await _quizService.generateQuiz(randomArticle, _articles);
              
              final quizData = await _quizService.getCurrentQuiz();
              if (mounted && (quizData['question']?.isNotEmpty ?? false)) {
                showDialog(
                  // ignore: use_build_context_synchronously
                  context: context,
                  builder: (context) => QuizDialog(quizData: quizData),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isDesktop ? 16.0 : 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadNews();
                  },
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                  vertical: isDesktop ? 16 : 12,
                ),
              ),
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _loadNews(searchQuery: value);
                }
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : _articles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.newspaper,
                                  size: isDesktop ? 80 : 60,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: isDesktop ? 24 : 16),
                                Text(
                                  'No news found',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 24 : 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadNews(),
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 16 : 8,
                                vertical: 8,
                              ),
                              itemCount: _articles.length,
                              itemBuilder: (context, index) {
                                return _buildNewsCard(_articles[index], isDesktop);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
