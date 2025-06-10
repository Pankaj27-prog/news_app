class Article {
  final String title;
  final String description;
  final String? urlToImage;
  final String url;
  final String source;
  final String publishedAt;
  final String? content;

  Article({
    required this.title,
    required this.description,
    this.urlToImage,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      urlToImage: json['urlToImage'],
      url: json['url'] ?? '',
      source: json['source']['name'] ?? 'Unknown Source',
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'urlToImage': urlToImage,
      'url': url,
      'source': {'name': source},
      'publishedAt': publishedAt,
      'content': content,
    };
  }
} 