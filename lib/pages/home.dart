import 'package:final_project/database/Category.dart';
import 'package:final_project/pages/HomePage.dart';
import 'package:final_project/pages/SearchResult.dart';
import 'package:final_project/pages/topicDetail.dart';
import 'package:final_project/pages/topicList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/colors.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<Home> {
  TextEditingController _search = TextEditingController();

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
    Color(0xFF00A8F5),
  ];
  final List<String> images = [
    'assets/images/bgcard2.png',
    'assets/images/bgcard1.png',
    'assets/images/bgcard3.png',
  ];

  @override
  void dispose() {
    super.dispose();
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 70,
              ),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Find Anything!',
                      style: TextStyle(
                          fontFamily: 'Nunito-Bold',
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    Text(
                      'Searching anything you want to learn here.',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          color: ColorCustom.textGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    SizedBox(
                      height: 45,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                          controller: _search,
                          cursorColor: Colors.blue,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            suffixIcon: IconButton(
                              icon: Image.asset('assets/images/search.png',
                                  width: 25, height: 25, color: Colors.black),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SearchResult(searchInfo: _search.text),
                                  ),
                                );
                              },
                            ),
                          ),
                          onChanged: (text) {
                            setState(() {});
                          }),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 130,
                          child: Text(
                            'Choose     a category',
                            style: TextStyle(
                                fontFamily: 'Nunito-Bold', fontSize: 24),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 170, // Chiều cao của ListView
                      child: ListView.builder(
                        scrollDirection:
                            Axis.horizontal, // Cuộn theo chiều ngang
                        itemCount:
                            items.length, // Số lượng item trong danh sách
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Xử lý sự kiện khi tap vào Container
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TopicList(
                                      categoryLabel: items[index].nameCategory),
                                ),
                              );
                              print(
                                  'Tapped on item ${items[index].nameCategory}');
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 15),
                              width: 130,
                              height: 170,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length].withOpacity(
                                    0.9), // Màu sắc xen kẽ với độ trong suốt
                                borderRadius: BorderRadius.circular(30),
                                image: DecorationImage(
                                  image:
                                      AssetImage(images[index % images.length]),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    colors[index % colors.length]
                                        .withOpacity(0.8),
                                    BlendMode.srcATop,
                                  ),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 10, 0, 0),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 10, 0, 5),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        items[index].nameCategory,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Nunito',
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          8.0), // Khoảng cách giữa text và bottom
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
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    Container(
                      // color: Colors.red,
                      child: Row(
                        children: [
                          Text(
                            'Topic outstanding',
                            style: TextStyle(
                                fontSize: 24, fontFamily: 'Nunito-Bold'),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(selectedIndex: 1)),
                                (route) => false, // Chuyển đến Library
                              );
                            },
                            child: Text(
                              'view all',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: ColorCustom.blueButton),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ///xu ly o day
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TopicDetail(topicLabel: 'Vegetables'),
                          ),
                        );
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                              width: 50, // Adjust the width as needed
                              height: 50, // Adjust the height as needed
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/raucu.png'),
                                  fit: BoxFit.cover,
                                ),
                                color: Colors.blue, // Blue background
                                borderRadius:
                                    BorderRadius.circular(20), // Border radius
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15), // Adjust the padding as needed
                              child: Text(
                                'Vegetables',
                                style: TextStyle(
                                  fontSize:
                                      18, // Adjust the font size as needed
                                  fontFamily: 'Nunito',
                                  color: Colors
                                      .black, // Adjust the text color as needed
                                ),
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.all(0),
                              child: Container(
                                width: 50, // Adjust the width as needed
                                height: 50, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  color:
                                      ColorCustom.squareGrey, // Blue background
                                  borderRadius: BorderRadius.circular(
                                      20), // Border radius
                                ),
                                child: Center(
                                  child: Container(
                                    width: 28, // Adjust the width as needed
                                    height: 28, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: Colors.white, // White background
                                      borderRadius: BorderRadius.circular(
                                          0), // Border radius
                                    ),
                                    child: Image.asset('assets/images/next.png',
                                        width: 25,
                                        height: 25,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        ///xuly
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TopicDetail(topicLabel: 'Mammals'),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 50, // Adjust the width as needed
                            height: 50, // Adjust the height as needed
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/animal.png'),
                                fit: BoxFit.cover,
                              ),
                              color: Colors.blue, // Blue background
                              borderRadius:
                                  BorderRadius.circular(20), // Border radius
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15), // Adjust the padding as needed
                            child: Text(
                              'Mammals',
                              style: TextStyle(
                                fontSize: 18, // Adjust the font size as needed
                                fontFamily: 'Nunito',
                                color: Colors
                                    .black, // Adjust the text color as needed
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.all(0),
                            child: Container(
                              width: 50, // Adjust the width as needed
                              height: 50, // Adjust the height as needed
                              decoration: BoxDecoration(
                                color:
                                    ColorCustom.squareGrey, // Blue background
                                borderRadius:
                                    BorderRadius.circular(20), // Border radius
                              ),
                              child: Center(
                                child: Container(
                                  width: 28, // Adjust the width as needed
                                  height: 28, // Adjust the height as needed
                                  decoration: BoxDecoration(
                                    color: Colors.white, // White background
                                    borderRadius: BorderRadius.circular(
                                        0), // Border radius
                                  ),
                                  child: Image.asset('assets/images/next.png',
                                      width: 25,
                                      height: 25,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TopicDetail(topicLabel: 'Beverages'),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 50, // Adjust the width as needed
                            height: 50, // Adjust the height as needed
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/drink.png'),
                                fit: BoxFit.cover,
                              ),
                              color: Colors.blue, // Blue background
                              borderRadius:
                                  BorderRadius.circular(20), // Border radius
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15), // Adjust the padding as needed
                            child: Text(
                              'Beverages',
                              style: TextStyle(
                                fontSize: 18, // Adjust the font size as needed
                                fontFamily: 'Nunito',
                                color: Colors
                                    .black, // Adjust the text color as needed
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.all(0),
                            child: Container(
                              width: 50, // Adjust the width as needed
                              height: 50, // Adjust the height as needed
                              decoration: BoxDecoration(
                                color:
                                    ColorCustom.squareGrey, // Blue background
                                borderRadius:
                                    BorderRadius.circular(20), // Border radius
                              ),
                              child: Center(
                                child: Container(
                                  width: 28, // Adjust the width as needed
                                  height: 28, // Adjust the height as needed
                                  decoration: BoxDecoration(
                                    color: Colors.white, // White background
                                    borderRadius: BorderRadius.circular(
                                        0), // Border radius
                                  ),
                                  child: Image.asset('assets/images/next.png',
                                      width: 25,
                                      height: 25,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
