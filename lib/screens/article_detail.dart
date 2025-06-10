import 'package:flutter/material.dart';
// import 'package:/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../services/bookmark_service.dart';
import '../services/summary_service.dart';
import '../services/tts_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  final SummaryService _summaryService = SummaryService();
  final TTSService _ttsService = TTSService();
  bool _isBookmarked = false;
  String? _summary;
  bool _isLoadingSummary = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _generateSummary();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _checkBookmarkStatus() async {
    try {
      final isBookmarked = await _bookmarkService.isArticleBookmarked(widget.article);
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });
      }
    } catch (e) {
      // Silent error handling for bookmark status
    }
  }

  Future<void> _generateSummary() async {
    if (widget.article.content == null || widget.article.content!.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingSummary = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No content available to generate summary'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    
    setState(() {
      _isLoadingSummary = true;
      _summary = null;
    });

    try {
      final summary = await _summaryService.getArticleSummary(widget.article.content!);
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoadingSummary = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSummary = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate summary: ${e.toString()}'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _generateSummary,
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleBookmark() async {
    try {
      await _bookmarkService.toggleBookmark(widget.article);
      if (mounted) {
        setState(() {
          _isBookmarked = !_isBookmarked;
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

  Future<void> _launchUrl() async {
    try {
      final Uri url = Uri.parse(widget.article.url);
      if (!await launchUrl(url)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the article')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the article')),
        );
      }
    }
  }

  Future<void> _toggleSpeech() async {
    try {
      if (_isSpeaking) {
        await _ttsService.stop();
        setState(() {
          _isSpeaking = false;
        });
      } else {
        final textToRead = [
          widget.article.title,
          widget.article.description,
          if (widget.article.content != null) widget.article.content!,
        ].join('. ');
        
        await _ttsService.speak(textToRead);
        setState(() {
          _isSpeaking = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to read article'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
              color: _isSpeaking ? Colors.amber : null,
            ),
            onPressed: _toggleSpeech,
          ),
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.article.urlToImage != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.article.urlToImage!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.amber[700],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.newspaper,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Article Image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.source, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        widget.article.source,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        widget.article.publishedAt,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingSummary)
                    const Center(child: CircularProgressIndicator())
                  else if (_summary != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber[100]!.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.auto_awesome,
                                  color: Colors.amber[800],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'TL;DR Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _summary!,
                            style: TextStyle(
                              color: Colors.amber[900],
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _summary!.startsWith('No content') || _summary!.length < 50
                                    ? Icons.info_outline
                                    : Icons.psychology,
                                color: Colors.amber[700],
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _summary!.startsWith('No content')
                                    ? 'No content available'
                                    : _summary!.length < 50
                                        ? 'Basic summary'
                                        : 'AI-generated summary',
                                style: TextStyle(
                                  color: Colors.amber[700],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    widget.article.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (widget.article.content != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.article.content!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchUrl,
                      icon: const Icon(Icons.launch),
                      label: const Text('Read Full Article'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 