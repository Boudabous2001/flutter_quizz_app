import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Challenge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const QuizHomeScreen(),
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({Key? key}) : super(key: key);

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  final List<Question> _questions = [
    Question(
      text: "Quelle est la capitale de la France ?",
      options: ["Lyon", "Paris", "Marseille", "Toulouse"],
      correctAnswerIndex: 1,
    ),
    Question(
      text: "Combien de continents existe-t-il ?",
      options: ["5", "6", "7", "8"],
      correctAnswerIndex: 2,
    ),
    Question(
      text: "Quel est le plus grand océan du monde ?",
      options: ["Atlantique", "Indien", "Arctique", "Pacifique"],
      correctAnswerIndex: 3,
    ),
    Question(
      text: "Qui a peint la Joconde ?",
      options: ["Van Gogh", "Picasso", "Léonard de Vinci", "Monet"],
      correctAnswerIndex: 2,
    ),
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedAnswerIndex;
  Timer? _timer;
  int _timeRemaining = 15;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _handleTimeOut();
        }
      });
    });
  }

  void _handleTimeOut() {
    _timer?.cancel();
    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = null;
    });
    _moveToNextQuestion();
  }

  void _answerQuestion(int selectedIndex) {
    _timer?.cancel();
    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = selectedIndex;

      if (selectedIndex ==
          _questions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      _moveToNextQuestion();
    });
  }

  void _moveToNextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswerIndex = null;
        _timeRemaining = 15;
        _startTimer();
      } else {
        // Quiz terminé
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => QuizResultScreen(
                    score: _score, totalQuestions: _questions.length)));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Challenge'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text('Score: $_score'),
              backgroundColor: Colors.amber[100],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: _timeRemaining / 15,
              backgroundColor: Colors.grey[300],
              color: _timeRemaining > 5 ? Colors.green : Colors.red,
              minHeight: 10,
            ),
            const SizedBox(height: 16),
            Text(
              'Temps restant: $_timeRemaining s',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _timeRemaining > 5 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              currentQuestion.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ...currentQuestion.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;

              Color getColor() {
                if (_isAnswered) {
                  if (index == currentQuestion.correctAnswerIndex) {
                    return Colors.green.shade100;
                  }
                  if (index == _selectedAnswerIndex) {
                    return Colors.red.shade100;
                  }
                }
                return Colors.white;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: _isAnswered ? null : () => _answerQuestion(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getColor(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: _isAnswered &&
                              index == currentQuestion.correctAnswerIndex
                          ? Colors.green.shade800
                          : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizResultScreen(
      {Key? key, required this.score, required this.totalQuestions})
      : super(key: key);

  String _getResultMessage() {
    final percentage = (score / totalQuestions * 100).round();

    if (percentage == 100) return 'Parfait ! 🏆';
    if (percentage >= 75) return 'Excellent travail ! 👏';
    if (percentage >= 50) return 'Pas mal ! Continuez comme ça. 👍';
    return 'Encore un peu de pratique. 💪';
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Résultats du Quiz',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 32),
            Text(
              '$score / $totalQuestions',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 32),
            Text(
              _getResultMessage(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuizHomeScreen()));
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Recommencer', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
