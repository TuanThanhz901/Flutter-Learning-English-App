import 'package:final_project/database/Topic.dart';
import 'package:final_project/pages/HomePage.dart';
import 'package:final_project/pages/topicDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TopicList extends StatefulWidget {
  String categoryLabel;

  TopicList({Key? key, required this.categoryLabel}) : super(key: key);
  @override
  _TopicListWidgetState createState() => _TopicListWidgetState();
}

class _TopicListWidgetState extends State<TopicList> {
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController _nameCategoryController = TextEditingController();
  List<TopicModel> topics = [];

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
    _nameCategoryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameCategoryController = TextEditingController(text: widget.categoryLabel);
    fetchListTopic();
  }

  void fetchListTopic() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value;

      List<TopicModel> loadedItems = [];
      if (data is Map<dynamic, dynamic>) {
        for (var item in data.values) {
          if (item != null && item is Map<dynamic, dynamic>) {
            var topic = TopicModel.fromMap(item);
            if (topic.category == widget.categoryLabel) {
              if (!topic.private || topic.author == user?.email) {
                loadedItems.add(topic);
              }
            }
          }
        }
      } else if (data is List<dynamic>) {
        for (var item in data) {
          if (item != null && item is Map<dynamic, dynamic>) {
            var topic = TopicModel.fromMap(item);
            if (topic.category == widget.categoryLabel) {
              if (topic.private == true && topic.author == user?.email) {
                loadedItems.add(topic);
              } else if (topic.private == false) {
                loadedItems.add(topic);
              }
            }
          }
        }
      }

      setState(() {
        topics = loadedItems;
      });
    } else {
      print('No data available.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryLabel,
          style: TextStyle(fontFamily: 'Nunito', fontSize: 30),
        ),
        leading: IconButton(
          icon: Image.asset('assets/images/return.png', width: 30, height: 30),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(selectedIndex: 1),
              ),
              (route) => false, // Chuyển đến Library
            );
          },
        ),
        actions: [
          Row(
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(top: 5.0),
              //   child: IconButton(
              //     icon: Icon(Icons.file_upload, size: 35),
              //     onPressed: () {
              //       // Xử lý uploadFile ở đây
              //     },
              //   ),
              // ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 30,
                ),
                onSelected: (String result) {
                  switch (result) {
                    case 'add':
                      //add topic logic here
                      _showAddTopicDialog(context);
                      break;
                    case 'update':
                      _showEditNameCategory(context, widget.categoryLabel);
                      print('filter 2 clicked');
                      break;
                    case 'remove':
                      //add logic here
                      showDeleteCategoryDialog(context, widget.categoryLabel);
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
                            'Add topic',
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
                            'Edit category',
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
                            'Delete category',
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            if (topics.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Category has no topics yet!',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Số lượng item trong mỗi dòng
                  crossAxisSpacing: 10, // Khoảng cách ngang giữa các item
                  mainAxisSpacing: 10, // Khoảng cách dọc giữa các item
                  childAspectRatio:
                      1, // Tỷ lệ chiều rộng/chiều cao của mỗi item
                ),
                itemCount: topics.length, // Số lượng item trong danh sách
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Xử lý sự kiện khi tap vào Container
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TopicDetail(topicLabel: topics[index].topicName),
                        ),
                      );
                      print('Tapped on item ${topics[index].topicName}');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors[index % colors.length].withOpacity(
                            0.9), // Màu sắc xen kẽ với độ trong suốt
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                          image: AssetImage(images[index % images.length]),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            colors[index % colors.length].withOpacity(0.8),
                            BlendMode.srcATop,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 10, 0, 0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Icon(
                                icons[index % icons.length],
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                topics[index].topicName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Nunito',
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: 8.0), // Khoảng cách giữa text và bottom
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTopicDialog(BuildContext context) {
    TextEditingController topicNameController = TextEditingController();

    bool publicTopic = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Topic'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: topicNameController,
                    decoration: InputDecoration(hintText: 'Enter Topic name'),
                  ),
                  SizedBox(
                    height: 10,
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
              onPressed: () {
                if (topicNameController.text.isNotEmpty) {
                  _addTopicToFirebase(
                    widget.categoryLabel,
                    topicNameController.text,
                    publicTopic,
                  );
                  Navigator.of(context).pop();
                } else {
                  // Show an error message or a toast
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addTopicToFirebase(
      String category, String topicName, bool publicTopic) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case when the user is not logged in
      return;
    }

    String author = user.email ?? 'Anonymous';

    TopicModel newTopic = TopicModel(
      category: category,
      topicName: topicName,
      private: !publicTopic,
      author: author,
      listWord: [],
    );

    DatabaseReference ref = FirebaseDatabase.instance.ref("Topic");
    await ref.push().set(newTopic.toMap());
    Fluttertoast.showToast(
      msg: "Topic added successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    fetchListTopic();
  }

  void _showEditNameCategory(BuildContext context, String categoryLabel) {
    TextEditingController _nameCategoryController =
        TextEditingController(text: categoryLabel);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: Container(
            height: 150,
            child: Column(
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
                  controller: _nameCategoryController,
                  decoration:
                      InputDecoration(hintText: 'Enter new category name'),
                ),
                SizedBox(
                  height: 15,
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
              child: Text('Save'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                String newCategoryName = _nameCategoryController.text.trim();
                if (newCategoryName.isNotEmpty) {
                  await _updateCategoryName(categoryLabel, newCategoryName);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCategoryName(
      String oldCategoryName, String newCategoryName) async {
    // Update category name in Category table
    DatabaseReference categoryRef = FirebaseDatabase.instance.ref("Category");
    DatabaseReference topicRef = FirebaseDatabase.instance.ref("Topic");
    final categorySnapshot = await categoryRef.get();

    if (categorySnapshot.exists) {
      final categoryData = categorySnapshot.value as Map<dynamic, dynamic>;
      String? categoryKey;
      for (var key in categoryData.keys) {
        if (categoryData[key]['nameCategory'] == oldCategoryName) {
          categoryKey = key;
          break;
        }
      }

      if (categoryKey != null) {
        await categoryRef
            .child(categoryKey)
            .update({'nameCategory': newCategoryName});
        setState(() {
          widget.categoryLabel = newCategoryName;
        });
      }
    }

    // Update category name in Topic table
    final topicSnapshot = await topicRef.get();
    if (topicSnapshot.exists) {
      final topicData = topicSnapshot.value as Map<dynamic, dynamic>;
      for (var key in topicData.keys) {
        if (topicData[key]['category'] == oldCategoryName) {
          await topicRef.child(key).update({'category': newCategoryName});
        }
      }
    }
    fetchListTopic();
    // Fetch th
    //e updated categories and topics to refresh the UI
  }

  void showDeleteCategoryDialog(BuildContext context, String categoryLabel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure delete category ${widget.categoryLabel}?'),
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
                await deleteCategoryAndRelatedTopics(categoryLabel);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteCategoryAndRelatedTopics(String categoryLabel) async {
    // Xóa Category từ Firebase Realtime Database
    DatabaseReference categoryRef = FirebaseDatabase.instance.ref("Category");
    final categorySnapshot = await categoryRef.get();
    if (categorySnapshot.exists) {
      final categoryData = categorySnapshot.value;

      if (categoryData is Map<dynamic, dynamic>) {
        String? categoryKey;
        for (var key in categoryData.keys) {
          if (categoryData[key]['nameCategory'] == categoryLabel) {
            categoryKey = key;
            break;
          }
        }

        if (categoryKey != null) {
          await categoryRef.child(categoryKey).remove();
        }
      } else if (categoryData is List<dynamic>) {
        for (int i = 0; i < categoryData.length; i++) {
          if (categoryData[i] != null &&
              categoryData[i]['nameCategory'] == categoryLabel) {
            await categoryRef.child(i.toString()).remove();
          }
        }
      }
    }

    // Xóa các Topic liên quan từ Firebase Realtime Database
    DatabaseReference topicRef = FirebaseDatabase.instance.ref("Topic");
    final topicSnapshot = await topicRef.get();
    if (topicSnapshot.exists) {
      final topicData = topicSnapshot.value;

      if (topicData is Map<dynamic, dynamic>) {
        for (var key in topicData.keys) {
          if (topicData[key]['category'] == categoryLabel) {
            await topicRef.child(key).remove();
          }
        }
      } else if (topicData is List<dynamic>) {
        for (int i = 0; i < topicData.length; i++) {
          if (topicData[i] != null &&
              topicData[i]['category'] == categoryLabel) {
            await topicRef.child(i.toString()).remove();
          }
        }
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(selectedIndex: 1)),
        (route) => false, // Chuyển đến Library
      );
      Fluttertoast.showToast(
        msg: "Topic added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
