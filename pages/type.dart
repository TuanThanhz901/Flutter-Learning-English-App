import 'package:final_project/colors.dart';
import 'package:final_project/database/Topic.dart';
import 'package:final_project/database/TopicPoint.dart';
import 'package:final_project/database/User.dart';
import 'package:final_project/database/Vocabulary.dart';
import 'package:final_project/pages/topicDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class TypeWord extends StatefulWidget {
  final String topicLabel;
  final String language;
  final bool random;
  final bool onlyStar;
  TypeWord(
      {Key? key,
      required this.topicLabel,
      required this.language,
      required this.random,
      required this.onlyStar})
      : super(key: key);
  @override
  _TypeWordWidgetState createState() => _TypeWordWidgetState();
}

class _TypeWordWidgetState extends State<TypeWord>
    with SingleTickerProviderStateMixin {
  List<VocabularyEntry> vocabulary = [];
  List<VocabularyEntry> filteredVocabulary = [];

  int current = 0;
  bool answered = false;

  TextEditingController _controller = TextEditingController();
  IconData? suffixIcon;
  VocabularyEntry? currentQuestion;
  List<String> options = [];
  int currentQuestionIndex = 0;
  String selectedAnswer = '';
  int correctQuestion = 0;
  Color? suffixIconColor;

  @override
  void initState() {
    super.initState();
    fetchListWord();
  }

  void fetchListWord() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (var item in data.values) {
        if (item != null) {
          var topic = TopicModel.fromMap(item);
          if (topic.topicName == widget.topicLabel) {
            setState(() {
              vocabulary.addAll(topic.listWord);
              filterVocabulary();
              if (widget.random) {
                filteredVocabulary.shuffle(Random());
              }
              if (filteredVocabulary.isNotEmpty) {
                currentQuestion = filteredVocabulary[current];
              }
            });
            break;
          }
        }
      }
    } else {
      print('No data available.');
    }
  }

  void filterVocabulary() {
    setState(() {
      if (widget.onlyStar) {
        filteredVocabulary = vocabulary.where((entry) => entry.star).toList();
      } else {
        filteredVocabulary = List.from(vocabulary);
      }
      if (filteredVocabulary.isNotEmpty) {
        currentQuestion = filteredVocabulary[current];
      }
    });
  }

  void checkAnswer() {
    if (currentQuestion == null) return;
    setState(() {
      answered = true;
      String correctAnswer = widget.language == 'English'
          ? currentQuestion!.vietnamese
          : currentQuestion!.english;

      if (_controller.text.trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase()) {
        suffixIcon = Icons.check;
        suffixIconColor = Colors.green;
        correctQuestion++;
      } else {
        suffixIcon = Icons.close;
        suffixIconColor = Colors.red;
      }
    });
  }

  void nextQuestion() {
    setState(() {
      if (current < filteredVocabulary.length - 1) {
        current++;
        currentQuestion = filteredVocabulary[current];
        _controller.clear();
        suffixIcon = null;
        answered = false;
      } else {
        // Nếu đã đến câu hỏi cuối cùng, có thể thêm logic để kết thúc bài quiz hoặc lặp lại từ đầu
        saveUserPoints(widget.topicLabel, correctQuestion);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Quiz Completed'),
            content: Text(
                'Your Score $correctQuestion/${filteredVocabulary.length}'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          TopicDetail(topicLabel: widget.topicLabel)));
                },
                child: Text('Oke'),
              ),
            ],
          ),
        );
      }
    });
  }

  /////point
  Future<void> saveUserPoints(String topicLabel, int correctAnswer) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference ref = FirebaseDatabase.instance.ref("users");
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        if (data != null) {
          for (var key in data.keys) {
            var item = data[key];
            if (item != null && item is Map<dynamic, dynamic>) {
              var userModel = UserModel.fromMap(item);
              if (userModel.email == user.email) {
                bool topicExists = false;

                for (var point in userModel.listPoint) {
                  if (point.nameTopic == topicLabel) {
                    topicExists = true;
                    if (correctAnswer > point.point) {
                      point.point = correctAnswer;
                    }
                    break;
                  }
                }

                if (!topicExists) {
                  var newTopicPoint =
                      TopicPoint(nameTopic: topicLabel, point: correctAnswer);
                  userModel.listPoint.add(newTopicPoint);
                }

                // Save the updated user data back to the database
                await ref.child(key).update(userModel.toMap());
                print('User points updated successfully.');
                return;
              }
            }
          }
        } else {
          print('Data is not a map: ${data.runtimeType}');
        }
      } else {
        print('No data available or snapshot is null.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: filteredVocabulary.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 35,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => TopicDetail(
                                        topicLabel: widget.topicLabel)));
                          },
                        ),
                        Text(
                          '${current + 1}/${filteredVocabulary.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 25),
                        ),
                        SizedBox(
                          width: 20,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: LinearProgressIndicator(
                        value: (current + 1) / filteredVocabulary.length,
                        backgroundColor: Colors.grey[200],
                        color: Colors.blue,
                        minHeight: 8,
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Center(
                      child: Text(
                        widget.language == 'English'
                            ? 'Meaning of "${currentQuestion?.english}"?'
                            : currentQuestion?.vietnamese ?? '',
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(45, 45, 45, 0),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          hintText: widget.language == 'English'
                              ? 'Nhập nghĩa tiếng Việt'
                              : 'Enter the English meaning',
                          suffixIcon: suffixIcon != null
                              ? Icon(
                                  suffixIcon,
                                  color: suffixIconColor,
                                  size: 30,
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Center(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              30), // Apply borderRadius here
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorCustom.blueButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: answered ? nextQuestion : checkAnswer,
                          child: Text(
                            answered ? 'Next Question' : 'Check Answer',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Nunito',
                                fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
