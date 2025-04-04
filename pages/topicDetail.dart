import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

import 'package:file_picker/file_picker.dart';
import 'package:final_project/cards/showConfigFlashCard.dart';
import 'package:final_project/cards/showConfigMulti.dart';
import 'package:final_project/cards/showConfigType.dart';
import 'package:final_project/database/Category.dart';
import 'package:final_project/database/Topic.dart';
import 'package:final_project/database/Vocabulary.dart';
import 'package:final_project/pages/HomePage.dart';
import 'package:final_project/pages/RankOfTopic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:final_project/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'package:path/path.dart' as path;

class TopicDetail extends StatefulWidget {
  String topicLabel;

  TopicDetail({Key? key, required this.topicLabel}) : super(key: key);
  @override
  _TopicDetailWidgetState createState() => _TopicDetailWidgetState();
}

class _TopicDetailWidgetState extends State<TopicDetail> {
  final user = FirebaseAuth.instance.currentUser;

  FlutterTts flutterTts = FlutterTts();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _englishController = TextEditingController();
  TextEditingController _vietnameseController = TextEditingController();

  List<VocabularyEntry> vocabulary = [];
  late bool publicTopic = false;

  ///test
  String? selectedCategory;
  final TextEditingController categoryNameController = TextEditingController();
  List<String> categories = [];
  List<CategoryModel> items = [];

  final List<IconData> icons = [
    Icons.dark_mode,
    Icons.light_outlined,
    Icons.cloud_outlined,
    Icons.light_mode_outlined,
  ];
  final List<Color> colors = [
    Color(0xFF9DB0A3),
    Color(0xFF454655),
    Color.fromARGB(255, 96, 205, 255),
    Color.fromARGB(255, 138, 123, 255),
  ];
  final List<String> images = [
    'assets/images/bgcard2.png',
    'assets/images/bgcard1.png',
    'assets/images/bgcard3.png',
  ];
  @override
  void dispose() {
    _nameController.dispose();
    // _englishController.dispose();
    // _vietnameseController.dispose(); // Dispose the controller

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.topicLabel);
    getTopicDetails(widget.topicLabel);
    fetchCategories();
    fetchListWord();
  }

  void fetchCategories() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Category");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value;

      List<CategoryModel> loadedItems = [];
      List<String> loadedCategories = [];
      if (data is Map<dynamic, dynamic>) {
        for (var item in data.values) {
          if (item != null) {
            loadedCategories.add(item['nameCategory']);
            loadedItems.add(CategoryModel.fromMap(item));
          }
        }
      } else if (data is List<dynamic>) {
        for (var item in data) {
          if (item != null) {
            loadedCategories.add(item['nameCategory']);
            loadedItems.add(CategoryModel.fromMap(item));
          }
        }
      }

      if (mounted) {
        setState(() {
          categories = loadedCategories;
          items = loadedItems;
          selectedCategory = categories.isNotEmpty ? categories[0] : null;
        });
      }
    } else {
      print('No data available.');
    }
  }

  void fetchListWord() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value;

      if (data is Map<dynamic, dynamic>) {
        for (var item in data.values) {
          if (item != null && item is Map<dynamic, dynamic>) {
            var topic = TopicModel.fromMap(item);
            if (topic.topicName == widget.topicLabel) {
              setState(() {
                vocabulary.addAll(topic.listWord);
              });
              break; // Dừng vòng lặp khi tìm thấy topic trùng với topicLabel
            }
          }
        }
      } else if (data is List<dynamic>) {
        for (var item in data) {
          if (item != null && item is Map<dynamic, dynamic>) {
            var topic = TopicModel.fromMap(item);
            if (topic.topicName == widget.topicLabel) {
              setState(() {
                vocabulary.addAll(topic.listWord);
              });
              break; // Dừng vòng lặp khi tìm thấy topic trùng với topicLabel
            }
          }
        }
      }
    } else {
      print('No data available.');
    }
  }

  ///^

  Future<void> _speak(String text) async {
    try {
      await flutterTts.setLanguage('en-US');
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(text);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getTopicDetails(String widgetTopicLabel) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value;

      if (data is Map<dynamic, dynamic>) {
        for (var item in data.values) {
          if (item != null && item is Map<dynamic, dynamic>) {
            var topic = TopicModel.fromMap(item);
            if (topic.topicName == widget.topicLabel) {
              setState(() {
                publicTopic = topic.private;
                selectedCategory = topic.category;
              });
              break;
            }
          }
        }
      } else if (data is List<dynamic>) {
        for (var item in data) {
          if (item != null && item is Map<dynamic, dynamic>) {
            var topic = TopicModel.fromMap(item);
            if (topic.topicName == widget.topicLabel) {
              setState(() {
                publicTopic = topic.private;
                selectedCategory = topic.category;
              });
              break;
            }
          }
        }
      }
    } else {
      print('No data available.');
    }
  }

  void showDeleteWordDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure delete "${vocabulary[index].english}"?'),
          content: Text('It wil be delete permanently.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.black,
                backgroundColor: const Color.fromARGB(255, 205, 205, 205),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Oke'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                deleteVocabularyItem(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteVocabularyItem(int index) async {
    String englishWord = vocabulary[index].english;

    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (var item in data.keys) {
        var topic = data[item];
        if (topic != null && topic is Map<dynamic, dynamic>) {
          if (topic['topicName'] == widget.topicLabel) {
            List<dynamic> listWord =
                List<dynamic>.from(topic['listWord'] ?? []);
            listWord.removeWhere((word) => word['english'] == englishWord);

            await ref.child(item).update({'listWord': listWord});

            setState(() {
              vocabulary.removeAt(index);
            });

            break;
          }
        }
      }
    }
  }

  void _showUpdateWord(BuildContext context, int index) {
    // Điền trước dữ liệu hiện tại của mục được chọn vào các trường TextField
    _englishController.text = vocabulary[index].english;
    _vietnameseController.text = vocabulary[index].vietnamese;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update ${vocabulary[index].english}'),
          content: Container(
            height: 200,
            child: Column(
              children: [
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'English',
                      style: TextStyle(fontSize: 20, fontFamily: 'Nunito'),
                    ),
                  ],
                ),
                TextField(
                  controller: _englishController,
                  decoration: InputDecoration(hintText: 'Enter English word'),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Vietnamese',
                      style: TextStyle(fontSize: 20, fontFamily: 'Nunito'),
                    ),
                  ],
                ),
                TextField(
                  controller: _vietnameseController,
                  decoration:
                      InputDecoration(hintText: 'Enter Vietnamese meaning'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.black,
                backgroundColor: const Color.fromARGB(255, 205, 205, 205),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                await _updateWord(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateWord(int index) async {
    String newEnglishWord = _englishController.text.trim();
    String newVietnameseWord = _vietnameseController.text.trim();

    if (newEnglishWord.isEmpty || newVietnameseWord.isEmpty) {
      // Hiển thị thông báo lỗi nếu cần
      return;
    }

    // Cập nhật mục từ vựng trong danh sách
    setState(() {
      vocabulary[index].english = newEnglishWord;
      vocabulary[index].vietnamese = newVietnameseWord;
    });

    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (var item in data.keys) {
        var topic = data[item];
        if (topic != null && topic is Map<dynamic, dynamic>) {
          if (topic['topicName'] == widget.topicLabel) {
            List<dynamic> listWord =
                List<dynamic>.from(topic['listWord'] ?? []);
            listWord[index]['english'] = newEnglishWord;
            listWord[index]['vietnamese'] = newVietnameseWord;

            await ref.child(item).update({'listWord': listWord});
            break;
          }
        }
      }
    }
  }

  //////Uploadfile
  Future<void> _uploadCSV() async {
    // Mở file picker để chọn file CSV
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      // Đọc file CSV
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      // Cập nhật từ vựng vào cơ sở dữ liệu
      await _addVocabularyFromCSV(fields);
    } else {
      // Người dùng không chọn file
      Fluttertoast.showToast(
        msg: "No file selected",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _addVocabularyFromCSV(List<List<dynamic>> fields) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (var item in data.keys) {
        var topic = data[item];
        if (topic != null && topic is Map<dynamic, dynamic>) {
          if (topic['topicName'] == widget.topicLabel) {
            List<dynamic> listWord =
                List<dynamic>.from(topic['listWord'] ?? []);

            for (var row in fields) {
              if (row.length >= 2) {
                String english = row[0].toString().trim();
                String vietnamese = row[1].toString().trim();

                // Kiểm tra nếu từ vựng đã tồn tại
                bool exists =
                    listWord.any((word) => word['english'] == english);
                if (!exists) {
                  listWord.add({
                    'english': english,
                    'vietnamese': vietnamese,
                    'star': false
                  });
                }
              }
            }

            await ref.child(item).update({'listWord': listWord});
            Fluttertoast.showToast(
              msg: "CSV uploaded successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            fetchListWord();
            break;
          }
        }
      }
    } else {
      print('No data available.');
    }
  }

  // Future<void> _exportToCSV() async {
  //   List<List<String>> data = [
  //     ["English", "Vietnamese"]
  //   ];

  //   for (var vocab in vocabulary) {
  //     data.add([vocab.english, vocab.vietnamese]);
  //   }

  //   String csvData = const ListToCsvConverter().convert(data);
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path = "${directory.path}/${widget.topicLabel}.csv";
  //   final file = File(path);

  //   await file.writeAsString(csvData);
  //   print({file.path});
  //   Fluttertoast.showToast(
  //     msg: 'CSV file saved: ${file.path}',
  //     toastLength: Toast.LENGTH_SHORT,
  //     gravity: ToastGravity.BOTTOM,
  //     timeInSecForIosWeb: 1,
  //     backgroundColor: Colors.green,
  //     textColor: Colors.white,
  //     fontSize: 16.0,
  //   );
  // }
  Future<String?> makeFile(
      BuildContext context, List<VocabularyEntry> words, String name) async {
    try {
      // Kiểm tra và yêu cầu quyền truy cập bộ nhớ
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
        var result = await Permission.manageExternalStorage.request();
        if (result != PermissionStatus.granted) {
          Fluttertoast.showToast(
            msg: 'Permission denied',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return null;
        }
      }

      // Tạo dữ liệu CSV
      List<List<dynamic>> rows = [];
      // rows.add(['English', 'Vietnamese']);
      for (var word in words) {
        rows.add([word.english, word.vietnamese]);
      }

      // Lấy đường dẫn thư mục lưu trữ
      Directory directory;
      if (Platform.isAndroid) {
        directory = Directory("/storage/emulated/0/Download");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      String appDocumentsPath = directory.path;

      // Tạo thư mục "orangecard" nếu nó chưa tồn tại
      String orangecardPath = '$appDocumentsPath/orangecard';
      Directory orangecardDirectory = Directory(orangecardPath);
      if (!(await orangecardDirectory.exists())) {
        await orangecardDirectory.create(recursive: true);
      }

      // Lưu tệp CSV
      String csvFilePath = '$orangecardPath/${name.replaceAll(" ", "")}.csv';
      File csvFile = File(csvFilePath);
      String csvData = const ListToCsvConverter().convert(rows);
      await csvFile.writeAsString(csvData);

      // Trả về đường dẫn tệp CSV nếu lưu thành công
      return csvFilePath;
    } catch (e) {
      // Xử lý lỗi
      print('Error saving file: $e');
      return null;
    }
  }

  void _saveCSV() async {
    String? filePath = await makeFile(context, vocabulary, widget.topicLabel);
    if (filePath != null) {
      Fluttertoast.showToast(
        msg: 'File saved: $filePath',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Error saving file',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _updateStarStatus(int index) async {
    setState(() {
      vocabulary[index].star = !vocabulary[index].star;
      fetchListWord();
    });

    // Update the star status in the Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (var item in data.keys) {
        if (data[item]['topicName'] == widget.topicLabel) {
          List<dynamic> listWord = data[item]['listWord'];
          for (int i = 0; i < listWord.length; i++) {
            if (listWord[i]['english'] == vocabulary[index].english) {
              listWord[i]['star'] = vocabulary[index].star;
              await ref.child(item).update({'listWord': listWord});
              break;
            }
          }
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topicLabel,
          style: TextStyle(fontFamily: 'Nunito', fontSize: 30),
        ),
        leading: IconButton(
          icon: Image.asset('assets/images/return.png', width: 30, height: 30),
          onPressed: () {
            // Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(selectedIndex: 1)),
              (route) => false, // Chuyển đến Library
            );
          },
        ),
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    ///Xử lý dowload file ở đây
                    _saveCSV();
                  },
                  icon: Icon(
                    Icons.download,
                    size: 30,
                  )),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 30,
                ),
                onSelected: (String result) {
                  switch (result) {
                    case 'add':
                      //add logic here
                      _showAddNewWord(context);
                      print('filter add word');
                      break;
                    case 'update':
                      //add logic here
                      _showEditNameTopic(context);
                      print('filter update topic');
                      break;
                    case 'upload':
                      _uploadCSV();

                      ///Code file upload here
                      break;
                    case 'remove':
                      //add logic here
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.confirm,
                        text: 'It will delete topic',
                        confirmBtnColor: Colors.green,
                        // confirmBtnText: 'Oke',
                        onConfirmBtnTap: () {
                          _deleteTopic();
                          Navigator.pop(context); // Đóng QuickAlert
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(selectedIndex: 1),
                            ),
                            (route) => false,
                          );
                        },
                      );

                      print('Delete');
                      break;
                    default:
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'add',
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          size: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Add new word',
                            style:
                                TextStyle(fontFamily: 'Nunito', fontSize: 13),
                          ),
                        )
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'update',
                    child: Row(
                      children: [
                        Icon(Icons.border_color_outlined),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Edit topic',
                            style:
                                TextStyle(fontFamily: 'Nunito', fontSize: 13),
                          ),
                        )
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'upload',
                    child: Row(
                      children: [
                        Icon(Icons.upload),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Upload file',
                            style:
                                TextStyle(fontFamily: 'Nunito', fontSize: 13),
                          ),
                        )
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Delete topic',
                            style:
                                TextStyle(fontFamily: 'Nunito', fontSize: 13),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  ///logic flashcard
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShowConfig(topicLabel: widget.topicLabel),
                    ),
                  );
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: ColorCustom.textGrey,
                    borderRadius: BorderRadius.circular(25), // Border radius
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Image.asset('assets/images/flashCard.png'),
                        ),
                      ),
                      Text(
                        'Flash Card',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontSize: 20),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  ///xu ly
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShowConfigMulti(topicLabel: widget.topicLabel),
                    ),
                  );
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: ColorCustom.textGrey,
                    borderRadius: BorderRadius.circular(25), // Border radius
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Image.asset('assets/images/multichoice.png'),
                        ),
                      ),
                      Text(
                        'Multi Choice',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontSize: 20),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  ///xuly
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShowConfigType(topicLabel: widget.topicLabel),
                    ),
                  );
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: ColorCustom.textGrey,
                    borderRadius: BorderRadius.circular(25), // Border radius
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Container(
                          width: 45,
                          height: 38,
                          child: Image.asset('assets/images/type.png'),
                        ),
                      ),
                      Text(
                        'Type',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RankOfTopic(topicLabel: widget.topicLabel),
                    ),
                    // (route) => false,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.auto_graph,
                          size: 40,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Rank",
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 23),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              if (vocabulary.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Topic has no words yet!',
                    style: TextStyle(
                        fontFamily: 'Nunito', fontSize: 18, color: Colors.red),
                  ),
                ),
              Container(
                height: 500,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: vocabulary.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                      key: ValueKey(index),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              // Gọi hàm update ở đây
                              _showUpdateWord(context, index);
                            },
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Update',
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          SlidableAction(
                            onPressed: (context) {
                              // Gọi hàm delete ở đây

                              showDeleteWordDialog(context, index);
                            },
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Card(
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      vocabulary[index].english,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.volume_up),
                                    onPressed: () {
                                      _speak(vocabulary[index].english);
                                      print(
                                          'Play sound for ${vocabulary[index].english}');
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _updateStarStatus(index);
                                      });
                                    },
                                    icon: Icon(vocabulary[index].star
                                        ? Icons.star
                                        : Icons.star_border),
                                  )
                                ],
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                vocabulary[index].vietnamese,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNewWord(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Word'),
          content: Container(
            height: 200,
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'English',
                      style: TextStyle(fontSize: 20, fontFamily: 'Nunito'),
                    ),
                  ],
                ),
                TextField(
                  controller: _englishController,
                  decoration: InputDecoration(hintText: 'Enter English word'),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Vietnamese',
                      style: TextStyle(fontSize: 20, fontFamily: 'Nunito'),
                    ),
                  ],
                ),
                TextField(
                  controller: _vietnameseController,
                  decoration:
                      InputDecoration(hintText: 'Enter Vietnamese meaning'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.black,
                backgroundColor: const Color.fromARGB(255, 205, 205, 205),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                await _addNewWord();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewWord() async {
    String englishWord = _englishController.text.trim();
    String vietnameseWord = _vietnameseController.text.trim();

    if (englishWord.isEmpty || vietnameseWord.isEmpty) {
      // Hiển thị thông báo lỗi nếu cần
      return;
    }

    VocabularyEntry newWord = VocabularyEntry(
      english: englishWord,
      vietnamese: vietnameseWord,
    );

    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (var item in data.keys) {
        var topic = data[item];
        if (topic != null && topic is Map<dynamic, dynamic>) {
          if (topic['topicName'] == widget.topicLabel) {
            // Cập nhật danh sách từ vựng
            List<dynamic> listWord =
                List<dynamic>.from(topic['listWord'] ?? []);
            listWord.add(newWord.toMap());

            // Cập nhật dữ liệu vào Firebase
            await ref.child(item).update({'listWord': listWord});

            // Cập nhật UI
            setState(() {
              vocabulary.add(newWord);
              _englishController.clear();
              _vietnameseController.clear();
            });

            break;
          }
        }
      }
    }
  }

  void _showEditNameTopic(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Topic'),
          content: Container(
            height: 250,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Name',
                          style: TextStyle(fontSize: 20, fontFamily: 'Nunito'),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: ''),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Select Category'),
                      value: selectedCategory,
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Text(
                          'Public topic:',
                          style: TextStyle(fontSize: 16, fontFamily: 'Nunito'),
                        ),
                        Spacer(),
                        CupertinoSwitch(
                          value: publicTopic,
                          onChanged: (bool newValue) {
                            setState(() {
                              publicTopic = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.black,
                backgroundColor: const Color.fromARGB(255, 205, 205, 205),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                await _editTopicName();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editTopicName() async {
    String newTopicName = _nameController.text.trim();

    if (newTopicName.isEmpty) {
      return;
    }

    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (var item in data.keys) {
        var topic = data[item];
        if (topic != null && topic is Map<dynamic, dynamic>) {
          if (topic['topicName'] == widget.topicLabel) {
            await ref.child(item).update({
              'topicName': newTopicName,
              'category': selectedCategory,
              'private': publicTopic,
            });

            setState(() {
              widget.topicLabel = newTopicName;
            });

            break;
          }
        }
      }
    }
  }

  Future<void> _deleteTopic() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (var item in data.keys) {
        var topic = data[item];
        if (topic != null && topic is Map<dynamic, dynamic>) {
          if (topic['topicName'] == widget.topicLabel) {
            // Xóa chủ đề
            await ref.child(item).remove();
            break;
          }
        }
      }
    }
  }
}
