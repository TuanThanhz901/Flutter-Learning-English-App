import 'package:final_project/database/Topic.dart';
import 'package:final_project/database/Vocabulary.dart';
import 'package:final_project/pages/topicDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_tts/flutter_tts.dart';

class FlashCard extends StatefulWidget {
  final String topicLabel;
  final String language;
  final bool random;
  final bool onlyStar;

  FlashCard(
      {Key? key,
      required this.topicLabel,
      required this.language,
      required this.random,
      required this.onlyStar})
      : super(key: key);

  @override
  _FlashCardWidgetState createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCard>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;

  late AnimationController _controller;
  bool isFront = true;

  List<VocabularyEntry> vocabulary = [];
  late List<VocabularyEntry> filteredVocabulary = [];
  int current = 0;

  FlutterTts flutterTts = FlutterTts();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    fetchListWord();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    });
  }

  void flipCard() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    isFront = !isFront;
  }

  void nextQuestion() {
    setState(() {
      isFront = true;
      _controller.reverse();
      if (current < filteredVocabulary.length - 1) {
        current++;
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Congatulation!'),
            content: Text('You done flash card ${widget.topicLabel}.'),
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

  void previousQuestion() {
    setState(() {
      isFront = true;
      _controller.reverse();
      if (current > 0) {
        current--;
      }
    });
  }

  Future<void> _speakEn(String text) async {
    try {
      await flutterTts.setLanguage('en-US');
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(text);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _speakVn(String text) async {
    try {
      await flutterTts.setLanguage('vi-VN');
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(text);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentVocabulary =
        filteredVocabulary.isNotEmpty ? filteredVocabulary[current] : null;
    final frontText = widget.language == 'English'
        ? currentVocabulary?.english ?? ''
        : currentVocabulary?.vietnamese ?? '';
    final backText = widget.language == 'English'
        ? currentVocabulary?.vietnamese ?? ''
        : currentVocabulary?.english ?? '';

    return SafeArea(
      child: Scaffold(
        body: Column(
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
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            TopicDetail(topicLabel: widget.topicLabel)));
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
                value: filteredVocabulary.isNotEmpty
                    ? (current + 1) / filteredVocabulary.length
                    : 0,
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
                minHeight: 8,
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Center(
              child: GestureDetector(
                onTap: flipCard,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final angle = _controller.value * pi;
                    final transform = Matrix4.rotationY(angle);
                    return Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child: _controller.value <= 0.5
                          ? Container(
                              width: 300,
                              height: 400,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 45.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        maxLines: 2,
                                        frontText,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 24),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            if (widget.language == 'English') {
                                              _speakEn(frontText);
                                            } else {
                                              _speakVn(frontText);
                                            }
                                          },
                                          icon: Icon(
                                            Icons.volume_up,
                                            color: Colors.white,
                                            size: 30,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Transform(
                              transform: Matrix4.rotationY(pi),
                              alignment: Alignment.center,
                              child: Container(
                                width: 300,
                                height: 400,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 128, 31),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 45.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          maxLines: 2,
                                          backText,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              if (widget.language ==
                                                  'English') {
                                                _speakVn(backText);
                                              } else {
                                                _speakEn(backText);
                                              }
                                            },
                                            icon: Icon(
                                              Icons.volume_up,
                                              color: Colors.white,
                                              size: 30,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: 70,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: previousQuestion,
                    icon: Icon(
                      Icons.arrow_back,
                      size: 50,
                    )),
                SizedBox(
                  width: 90,
                ),
                IconButton(
                    onPressed: nextQuestion,
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 50,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
