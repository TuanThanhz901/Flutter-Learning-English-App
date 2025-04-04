import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('GridView Example'),
        ),
        body: GridViewExample(),
      ),
    );
  }
}

class GridViewExample extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {'label': 'Home', 'image': 'assets/image1.jpg', 'icon': Icons.home},
    {'label': 'Star', 'image': 'assets/image2.jpg', 'icon': Icons.star},
    {'label': 'Profile', 'image': 'assets/image3.jpg', 'icon': Icons.person},
    {'label': 'Settings', 'image': 'assets/image4.jpg', 'icon': Icons.settings},
    {'label': 'Phone', 'image': 'assets/image5.jpg', 'icon': Icons.phone},
    {'label': 'Map', 'image': 'assets/image6.jpg', 'icon': Icons.map},
    {'label': 'Camera', 'image': 'assets/image7.jpg', 'icon': Icons.camera},
    {'label': 'Computer', 'image': 'assets/image8.jpg', 'icon': Icons.computer},
  ];

  final List<Color> colors = [
    Color(0x809DB0A3), // 50% độ trong suốt
    Color(0x80454655), // 50% độ trong suốt
    Color(0x8000A8F5), // 50% độ trong suốt
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Số lượng item trong mỗi dòng
          crossAxisSpacing: 10, // Khoảng cách ngang giữa các item
          mainAxisSpacing: 10, // Khoảng cách dọc giữa các item
          childAspectRatio: 3 / 4, // Tỷ lệ chiều rộng/chiều cao của mỗi item
        ),
        itemCount: items.length, // Số lượng item trong danh sách
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Xử lý sự kiện khi tap vào Container
              print('Tapped on item ${items[index]['label']}');
            },
            child: Container(
              decoration: BoxDecoration(
                color: colors[index % colors.length]
                    .withOpacity(0.9), // Màu sắc xen kẽ với độ trong suốt
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: AssetImage(items[index]['image']),
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
                        items[index]['icon'],
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
                        items[index]['label'],
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
