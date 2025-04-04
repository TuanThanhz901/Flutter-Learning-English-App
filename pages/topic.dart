import 'package:final_project/database/Topic.dart';
import 'package:final_project/pages/topicDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Topic extends StatefulWidget {
  Topic({Key? key}) : super(key: key);
  @override
  _TopicWidgetState createState() => _TopicWidgetState();
}

class _TopicWidgetState extends State<Topic> {
  final user = FirebaseAuth.instance.currentUser;

  ///test
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

  ///^

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
            if (!topic.private || topic.author == user?.email) {
              loadedItems.add(topic);
            }
          }
        }
      } else if (data is List<dynamic>) {
        for (var item in data) {
          if (item != null && item is Map<dynamic, dynamic>) {
            var topic = TopicModel.fromMap(item);
            if (!topic.private || topic.author == user?.email) {
              loadedItems.add(topic);
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
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Số lượng item trong mỗi dòng
          crossAxisSpacing: 10, // Khoảng cách ngang giữa các item
          mainAxisSpacing: 10, // Khoảng cách dọc giữa các item
          childAspectRatio: 1, // Tỷ lệ chiều rộng/chiều cao của mỗi item
        ),
        itemCount: topics.length, // Số lượng item trong danh sách
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
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
                        topics[index].topicName,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0), // Khoảng cách giữa text và bottom
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
