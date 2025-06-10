import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

class QuizDialog extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const QuizDialog({super.key, required this.quizData});

  @override
  State<QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<QuizDialog> {
  final _quizService = QuizService();
  bool _isCorrect = false;
  bool _hasAnswered = false;
  String? _selectedOption;

  Future<void> _checkAnswer(String option) async {
    setState(() {
      _selectedOption = option;
    });

    final isCorrect = await _quizService.checkAnswer(option);
    setState(() {
      _isCorrect = isCorrect;
      _hasAnswered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;
    final options = (widget.quizData['options'] as List<dynamic>?)?.cast<String>() ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: isDesktop ? size.width * 0.4 : size.width * 0.9,
        padding: EdgeInsets.all(isDesktop ? 24 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: Colors.amber,
                    size: isDesktop ? 28 : 24,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Text(
                  'Daily News Quiz',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 24 : 20),
            Text(
              widget.quizData['question'] as String? ?? '',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isDesktop ? 12 : 8),
            Text(
              'Based on: ${widget.quizData['article'] as String? ?? ''}',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: isDesktop ? 20 : 16),
            ...options.map((option) => Padding(
              padding: EdgeInsets.only(bottom: isDesktop ? 12 : 8),
              child: InkWell(
                onTap: _hasAnswered ? null : () => _checkAnswer(option),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 16 : 12),
                  decoration: BoxDecoration(
                    color: _selectedOption == option
                        ? (_isCorrect ? Colors.green[50] : Colors.red[50])
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedOption == option
                          ? (_isCorrect ? Colors.green[200]! : Colors.red[200]!)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedOption == option
                            ? (_isCorrect ? Icons.check_circle : Icons.error)
                            : Icons.radio_button_unchecked,
                        color: _selectedOption == option
                            ? (_isCorrect ? Colors.green : Colors.red)
                            : Colors.grey,
                        size: isDesktop ? 24 : 20,
                      ),
                      SizedBox(width: isDesktop ? 16 : 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            color: _selectedOption == option
                                ? (_isCorrect ? Colors.green[700] : Colors.red[700])
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )).toList(),
            if (_hasAnswered) ...[
              SizedBox(height: isDesktop ? 20 : 16),
              Container(
                padding: EdgeInsets.all(isDesktop ? 16 : 12),
                decoration: BoxDecoration(
                  color: _isCorrect ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isCorrect ? Colors.green[200]! : Colors.red[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.error,
                      color: _isCorrect ? Colors.green : Colors.red,
                      size: isDesktop ? 24 : 20,
                    ),
                    SizedBox(width: isDesktop ? 12 : 8),
                    Expanded(
                      child: Text(
                        _isCorrect
                            ? 'Correct! Well done!'
                            : 'Incorrect. The answer was: ${widget.quizData['answer'] as String? ?? ''}',
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: _isCorrect ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isDesktop ? 20 : 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hasAnswered
                    ? () => Navigator.of(context).pop()
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isDesktop ? 16 : 12,
                    horizontal: isDesktop ? 24 : 16,
                  ),
                  backgroundColor: _hasAnswered ? Colors.grey : Colors.amber,
                  textStyle: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  _hasAnswered ? 'Close' : 'Select an option',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 