import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VocabularyList(),
    );
  }
}

class VocabularyList extends StatelessWidget {
  final List<Map<String, String>> vocabulary = [
    {'english': 'Hello', 'vietnamese': 'Xin chào'},
    {'english': 'Thank you', 'vietnamese': 'Cảm ơn'},
    {'english': 'Goodbye', 'vietnamese': 'Tạm biệt'},
    {'english': 'Please', 'vietnamese': 'Làm ơn'},
    {'english': 'Sorry', 'vietnamese': 'Xin lỗi'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vocabulary List'),
      ),
      body: ListView.builder(
        itemCount: vocabulary.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vocabulary[index]['english']!,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.volume_up),
                        onPressed: () {
                          // Xử lý sự kiện phát âm từ vựng ở đây
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    vocabulary[index]['vietnamese']!,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
