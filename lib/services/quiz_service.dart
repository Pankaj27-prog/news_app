import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';
// import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:convert';

class QuizService {
  static const String _lastQuizDateKey = 'last_quiz_date';
  // static const String _quizArticleKey = 'quiz_article';
  static const String _quizQuestionKey = 'quiz_question';
  static const String _quizAnswerKey = 'quiz_answer';
  // static const String _quizOptionsKey = 'quiz_options';

  Future<bool> shouldShowNewQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final lastQuizDate = prefs.getString(_lastQuizDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Also check if we have valid quiz data
    final hasQuizData = prefs.getString(_quizQuestionKey)?.isNotEmpty ?? false;
    
    return lastQuizDate != today || !hasQuizData;
  }

  List<String> _generateOptions(String correctAnswer, List<Article> allArticles) {
    final random = Random();
    final options = <String>[correctAnswer];
    
    // Get unique entities from other articles
    final otherEntities = allArticles
        .where((article) => article.title != correctAnswer)
        .map((article) {
          final words = article.title.split(' ');
          if (words.isNotEmpty) return words[0];
          return '';
        })
        .where((entity) => entity.isNotEmpty)
        .toSet()
        .toList();

    // Shuffle and take up to 3 unique options
    otherEntities.shuffle(random);
    for (var entity in otherEntities) {
      if (options.length < 4 && !options.contains(entity)) {
        options.add(entity);
      }
    }

    // If we don't have enough options, add some generic ones
    final genericOptions = ['The Government', 'A Local Company', 'International Organization'];
    while (options.length < 4) {
      final option = genericOptions[random.nextInt(genericOptions.length)];
      if (!options.contains(option)) {
        options.add(option);
      }
    }

    // Shuffle the options
    options.shuffle(random);
    return options;
  }

  String _generateQuestion(Article article) {
    final random = Random();
    final questionTypes = [
      'What is the main focus of this news article?',
      'Which entity is primarily involved in this news?',
      'What is the key development reported in this article?',
      'What is the central theme of this news story?',
      'What significant event is being reported here?'
    ];

    // Extract key information from the article
    final titleWords = article.title.split(' ');
    //final descriptionWords = article.description?.split(' ') ?? [];
    final descriptionWords = article.description.split(' ');
    
    // Combine title and description words for better context
    final allWords = [...titleWords, ...descriptionWords];
    
    // Find important entities (words that appear multiple times or are capitalized)
    final importantWords = allWords
        .where((word) => 
            word.length > 3 && 
            (word[0] == word[0].toUpperCase() || 
             allWords.where((w) => w.toLowerCase() == word.toLowerCase()).length > 1))
        .toSet()
        .toList();

    // Generate a question based on the content
    if (importantWords.isNotEmpty) {
      final randomWord = importantWords[random.nextInt(importantWords.length)];
      return 'What is the significance of "$randomWord" in this news article?';
    }

    // Fallback to random question type
    return questionTypes[random.nextInt(questionTypes.length)];
  }

  String _extractAnswer(Article article) {
    if (article.title.isEmpty) return '';

    final words = article.title.split(' ');
    if (words.isNotEmpty) {
      // Try to find the main entity (usually the first significant word)
      for (var word in words) {
        if (word.length > 3 && word[0] == word[0].toUpperCase()) {
          return word;
        }
      }
    }

    // If we couldn't find a good answer, use the first few words of the title
    return words.take(2).join(' ');
  }

  Future<void> generateQuiz(Article article, List<Article> allArticles) async {
    if (article.title.isEmpty) return;

    final question = _generateQuestion(article);
    final answer = _extractAnswer(article);
    final options = _generateOptions(answer, allArticles);

    final quizData = {
      'articleTitle': article.title,
      'question': question,
      'answer': answer,
      'options': options,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_quiz', jsonEncode(quizData));
    await prefs.setString('last_quiz_date', DateTime.now().toIso8601String());
  }

  Future<Map<String, dynamic>> getCurrentQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final quizJson = prefs.getString('current_quiz');
    if (quizJson == null) {
      return {
        'articleTitle': '',
        'question': '',
        'answer': '',
        'options': <String>[],
      };
    }
    return Map<String, dynamic>.from(jsonDecode(quizJson));
  }

  Future<bool> checkAnswer(String userAnswer) async {
    final prefs = await SharedPreferences.getInstance();
    final correctAnswer = prefs.getString(_quizAnswerKey) ?? '';
    
    return userAnswer.toLowerCase().trim() == correctAnswer.toLowerCase().trim();
  }
} 