import 'package:final_project/database/Topic.dart';
import 'package:final_project/database/TopicPoint.dart';
import 'package:final_project/database/User.dart';
import 'package:final_project/database/Vocabulary.dart';
import 'package:final_project/pages/topicDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class MultiChoice extends StatefulWidget {
  final String topicLabel;
  final String language;
  final bool random;
  final bool onlyStar;
  MultiChoice(
      {Key? key,
      required this.topicLabel,
      required this.language,
      required this.random,
      required this.onlyStar})
      : super(key: key);
  @override
  _MultiChoiceWidgetState createState() => _MultiChoiceWidgetState();
}

class _MultiChoiceWidgetState extends State<MultiChoice>
    with SingleTickerProviderStateMixin {
  int current = 1;
  List<VocabularyEntry> vocabulary = [];
  List<VocabularyEntry> filteredVocabulary = [];
  VocabularyEntry? currentQuestion;
  List<String> options = [];
  int currentQuestionIndex = 0;
  bool answered = false;
  int correctAnswer = 0;
  String selectedAnswer = '';

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
                generateQuestion();
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
    if (widget.onlyStar) {
      filteredVocabulary = vocabulary.where((entry) => entry.star).toList();
    } else {
      filteredVocabulary = List.from(vocabulary);
    }
  }

  void generateQuestion() {
    setState(() {
      currentQuestion = filteredVocabulary[currentQuestionIndex];

      List<VocabularyEntry> shuffledVocabulary = List.from(vocabulary)
        ..shuffle(Random());

      if (widget.language == 'English') {
        options = shuffledVocabulary
            .where((entry) => entry.english != currentQuestion!.english)
            .take(3)
            .map((entry) => entry.vietnamese)
            .toList();
        options.add(currentQuestion!.vietnamese);
      } else {
        options = shuffledVocabulary
            .where((entry) => entry.vietnamese != currentQuestion!.vietnamese)
            .take(3)
            .map((entry) => entry.english)
            .toList();
        options.add(currentQuestion!.english);
      }

      options.shuffle(Random());

      answered = false;
      selectedAnswer = '';
    });
  }

  void handleAnswer(String answer) {
    setState(() {
      answered = true;
      selectedAnswer = answer;
      if ((widget.language == 'English' &&
              answer == currentQuestion!.vietnamese) ||
          (widget.language == 'Vietnamese' &&
              answer == currentQuestion!.english)) {
        correctAnswer++;
      }
      Timer(Duration(seconds: 1), () {
        if (currentQuestionIndex < filteredVocabulary.length - 1) {
          currentQuestionIndex++;
          nextQuestion();
          generateQuestion();
        } else {
          //////////////////////////
          saveUserPoints(widget.topicLabel, correctAnswer);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Quiz Completed'),
              content: Text(
                  'Your Score $correctAnswer/${filteredVocabulary.length}'),
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
    });
  }

  void nextQuestion() {
    setState(() {
      if (current < filteredVocabulary.length) {
        current++;
      }
    });
  }

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
        body: filteredVocabulary.isEmpty
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
                        '${current}/${filteredVocabulary.length}',
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
                      value: current / filteredVocabulary.length,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue,
                      minHeight: 8,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 200, 15, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.language == 'English'
                              ? 'Meaning of "${currentQuestion?.english}"?'
                              : 'Meaning of "${currentQuestion?.vietnamese}"?',
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 80.0),
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.0,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                          ),
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            String option = options[index];
                            bool isCorrect = widget.language == 'English'
                                ? option == currentQuestion!.vietnamese
                                : option == currentQuestion!.english;
                            bool isSelected = option == selectedAnswer;

                            return GestureDetector(
                              onTap:
                                  !answered ? () => handleAnswer(option) : null,
                              child: Container(
                                padding: EdgeInsets.all(20.0),
                                margin: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  color: answered
                                      ? (isSelected
                                          ? (isCorrect
                                              ? Colors.green
                                              : Colors.red)
                                          : (isCorrect
                                              ? Colors.green
                                              : Colors.white))
                                      : Colors.white,
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Center(
                                  child: Text(
                                    option,
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                ),
                              ),
                            );
                          },
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
