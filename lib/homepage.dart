import 'package:christmas_bizzare/quizpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding/decoding JSON
import 'dart:ui'; // For BackdropFilter

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int userScore = 0;
  List<Map<String, dynamic>> leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedLeaderboard = prefs.getString('leaderboard');
    if (savedLeaderboard != null) {
      setState(() {
        leaderboard =
            List<Map<String, dynamic>>.from(json.decode(savedLeaderboard));
      });
    }
  }

  Future<void> _saveLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    String encodedLeaderboard = json.encode(leaderboard);
    prefs.setString('leaderboard', encodedLeaderboard);
  }

  Future<void> startQuiz() async {
    final returnedScore = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(username: widget.username),
      ),
    );

    if (returnedScore != null) {
      setState(() {
        userScore = returnedScore;
        leaderboard.add({
          'name': widget.username,
          'score': userScore,
        });
        leaderboard.sort((a, b) => b['score'].compareTo(a['score']));
      });
      _saveLeaderboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sortedLeaderboard = List.from(leaderboard);
    sortedLeaderboard.sort((a, b) => b['score'].compareTo(a['score']));

    return Scaffold(
      appBar: AppBar(
        title: Text('🎄 Hello, ${widget.username} 🎅'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        elevation: 10,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/Assets/images/background1.jpg', // Path to your background image
              fit: BoxFit.cover,
            ),
          ),
          // Content Overlay
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Leaderboard Text with a Blur Effect
                  Stack(
                    children: [
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal:
                                  32.0), // Increased padding for larger blur
                        ),
                      ),
                      Align(
                        alignment:
                            Alignment.center, // Align the text to the center
                        child: Text(
                          '🎖️ Leaderboard 🎖️',
                          style: TextStyle(
                            fontSize: 30, // Increased font size
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: sortedLeaderboard.map((player) {
                          return Card(
                            color: Colors.white,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.star, color: Colors.red[700]),
                              title: Text(
                                player['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[800],
                                ),
                              ),
                              trailing: Text(
                                'Score: ${player['score']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    color: Colors.red[100],
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Your Points',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '$userScore',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: startQuiz,
                    child: Text(
                      'Start Quiz',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
