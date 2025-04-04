import 'package:final_project/colors.dart';
import 'package:final_project/database/Category.dart';
import 'package:final_project/database/Topic.dart';
import 'package:final_project/pages/HomePage.dart';
import 'package:final_project/pages/topic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:final_project/pages/category.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Library extends StatefulWidget {
  Library({Key? key}) : super(key: key);

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> with SingleTickerProviderStateMixin {
  String? selectedCategory;
  final TextEditingController categoryNameController = TextEditingController();
  String? errorText;

  bool publicTopic = false;

  late TabController _tabController;
  int _currentIndex = 0;

  List<CategoryModel> items = [];
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    selectedCategory = categories.isNotEmpty ? categories[0] : null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    categoryNameController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon:
                  Image.asset('assets/images/topic.png', width: 25, height: 25),
              text: "Topic",
            ),
            Tab(
              icon: Image.asset('assets/images/category1.png',
                  width: 25, height: 25),
              text: 'Category',
            ),
          ],
          indicatorColor: ColorCustom.blueButton,
          labelStyle: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Nunito-Bold',
            color: ColorCustom.blueButton,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 16.0),
        ),
        title: const Text(
          'Library',
          style: TextStyle(fontFamily: 'Nunito', fontSize: 30),
        ),
        actions: [
          Row(
            children: [
              // _currentIndex == 0
              //     ? Padding(
              //         padding: const EdgeInsets.only(top: 5.0),
              //         child: IconButton(
              //           icon: Icon(Icons.file_upload, size: 35),
              //           onPressed: () {
              //             // Xử lý uploadFile ở đây
              //           },
              //         ),
              //       )
              //     : SizedBox.shrink(),
              IconButton(
                icon: Icon(Icons.add, size: 40),
                onPressed: () {
                  if (_currentIndex == 1) {
                    _showAddCategoryDialog(context);
                  } else if (_currentIndex == 0) {
                    _showAddTopicDialog(context);
                  }
                },
              ),
            ],
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Topic(),
          Category(),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Category'),
              content: TextField(
                controller: categoryNameController,
                decoration: InputDecoration(
                  hintText: 'Enter Category name',
                  errorText: errorText,
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
                  onPressed: () {
                    if (categoryNameController.text.trim().isEmpty) {
                      setState(() {
                        errorText = 'Category name cannot be empty';
                      });
                    } else {
                      _addCategory();
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addCategory() async {
    String categoryName = categoryNameController.text.trim();
    if (categoryName.isNotEmpty) {
      DatabaseReference ref = FirebaseDatabase.instance.ref("Category");
      String newKey = ref.push().key ?? "";
      await ref.child(newKey).set({
        'nameCategory': categoryName,
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(selectedIndex: 1)),
        (route) => false, // Chuyển đến Library
      );
      Fluttertoast.showToast(
        msg: "Category added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      fetchCategories();
    }
  }

  // void _showAddTopicDialog(BuildContext context) {
  //   TextEditingController topicNameController = TextEditingController();
  //   String? selectedCategory;
  //   bool publicTopic = true;

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Add Topic'),
  //         content: StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState) {
  //             return Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: topicNameController,
  //                   decoration: InputDecoration(hintText: 'Enter Topic name'),
  //                 ),
  //                 SizedBox(height: 20),
  //                 DropdownButtonFormField<String>(
  //                   decoration: InputDecoration(labelText: 'Select Category'),
  //                   value: selectedCategory,
  //                   items: categories.map((String category) {
  //                     return DropdownMenuItem<String>(
  //                       value: category,
  //                       child: Text(category),
  //                     );
  //                   }).toList(),
  //                   onChanged: (String? newValue) {
  //                     setState(() {
  //                       selectedCategory = newValue;
  //                     });
  //                   },
  //                 ),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 Row(
  //                   children: [
  //                     Text(
  //                       'Public topic:',
  //                       style: TextStyle(fontSize: 16, fontFamily: 'Nunito'),
  //                     ),
  //                     Spacer(),
  //                     CupertinoSwitch(
  //                       value: publicTopic,
  //                       onChanged: (bool newValue) {
  //                         setState(() {
  //                           publicTopic = newValue;
  //                         });
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //         actions: [
  //           TextButton(
  //             child: Text('Cancel'),
  //             style: TextButton.styleFrom(
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10)),
  //               foregroundColor: Colors.black,
  //               backgroundColor: const Color.fromARGB(255, 205, 205, 205),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('Add'),
  //             style: TextButton.styleFrom(
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10)),
  //               foregroundColor: Colors.white,
  //               backgroundColor: Colors.green,
  //             ),
  //             onPressed: () {
  //               if (selectedCategory != null &&
  //                   topicNameController.text.isNotEmpty) {
  //                 _addTopicToFirebase(
  //                   selectedCategory!,
  //                   topicNameController.text,
  //                   publicTopic,
  //                 );
  //                 Navigator.of(context).pop();
  //               } else {
  //                 // Show an error message or a toast
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  void _showAddTopicDialog(BuildContext context) {
    TextEditingController topicNameController = TextEditingController();
    String? selectedCategory;
    bool publicTopic = true;

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Topic'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: topicNameController,
                      decoration: InputDecoration(hintText: 'Enter Topic name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a topic name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
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
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
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
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addTopicToFirebase(
                    selectedCategory!,
                    topicNameController.text,
                    publicTopic,
                  );
                  Navigator.of(context).pop();
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

    fetchCategories();
  }
}
