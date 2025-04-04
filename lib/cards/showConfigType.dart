import 'package:final_project/pages/type.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:final_project/colors.dart';

class ShowConfigType extends StatefulWidget {
  final String topicLabel;

  ShowConfigType({Key? key, required this.topicLabel}) : super(key: key);
  @override
  _ShowConfigTypeWidgetState createState() => _ShowConfigTypeWidgetState();
}

class _ShowConfigTypeWidgetState extends State<ShowConfigType> {
  final user = FirebaseAuth.instance.currentUser;
  bool randomWord = false;
  bool starWords = false;

  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                Icons.close,
                size: 35,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Set Function',
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 30),
                  ),
                  Text(
                    'Choose a language',
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 20),
                  ),
                  ListTile(
                    title: Text('English'),
                    leading: Radio<String>(
                      activeColor: ColorCustom.blueButton,
                      value: 'English',
                      groupValue: selectedLanguage,
                      onChanged: (String? value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Vietnamese'),
                    leading: Radio<String>(
                      activeColor: ColorCustom.blueButton,
                      value: 'Vietnamese',
                      groupValue: selectedLanguage,
                      onChanged: (String? value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Random Word',
                        style: TextStyle(fontFamily: 'Nunito', fontSize: 20),
                      ),
                      SizedBox(
                        width: 36,
                      ),
                      CupertinoSwitch(
                        activeColor: ColorCustom.blueButton,
                        value: randomWord,
                        onChanged: (bool newValue) {
                          setState(() {
                            randomWord = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'Only star word',
                        style: TextStyle(fontFamily: 'Nunito', fontSize: 20),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      CupertinoSwitch(
                        activeColor: ColorCustom.blueButton,
                        value: starWords,
                        onChanged: (bool newValue) {
                          setState(() {
                            starWords = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 80,
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCustom.blueButton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TypeWord(
                                topicLabel: widget.topicLabel,
                                language: selectedLanguage,
                                random: randomWord,
                                onlyStar: starWords),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 150,
                        height: 55,
                        child: const Text(
                          'Go',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
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
