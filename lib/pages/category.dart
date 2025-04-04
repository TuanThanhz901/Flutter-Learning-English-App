import 'package:final_project/database/Category.dart';
import 'package:final_project/pages/topicList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Category extends StatefulWidget {
  Category({Key? key}) : super(key: key);
  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<Category> {
  final user = FirebaseAuth.instance.currentUser;

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
    super.dispose();
    fetchCategories();
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Category");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value;

      List<CategoryModel> loadedItems = [];
      if (data is Map<dynamic, dynamic>) {
        for (var item in data.values) {
          if (item != null) {
            loadedItems.add(CategoryModel.fromMap(item));
          }
        }
      } else if (data is List<dynamic>) {
        for (var item in data) {
          if (item != null) {
            loadedItems.add(CategoryModel.fromMap(item));
          }
        }
      }

      if (mounted) {
        setState(() {
          items = loadedItems;
        });
      }
    } else {
      print('No data available.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          // if (items.isEmpty)
          //   Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Text(
          //       'Topic has no words yet!',
          //       style: TextStyle(
          //         fontFamily: 'Nunito',
          //         fontSize: 18,
          //         color: Colors.red,
          //       ),
          //     ),
          //   ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Số lượng item trong mỗi dòng
                crossAxisSpacing: 10, // Khoảng cách ngang giữa các item
                mainAxisSpacing: 10, // Khoảng cách dọc giữa các item
                childAspectRatio: 1, // Tỷ lệ chiều rộng/chiều cao của mỗi item
              ),
              itemCount: items.length, // Số lượng item trong danh sách
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TopicList(
                          categoryLabel: items[index].nameCategory,
                        ),
                      ),
                    );
                    print('Tapped on item ${items[index].nameCategory}');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors[index % colors.length]
                          .withOpacity(0.9), // Màu sắc xen kẽ với độ trong suốt
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
                              items[index].nameCategory,
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
    );
  }
}
