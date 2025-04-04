import 'package:final_project/database/Vocabulary.dart';

class TopicModel {
  String category;
  String topicName;
  bool private;
  String author;
  List<VocabularyEntry> listWord;

  TopicModel({
    required this.category,
    required this.topicName,
    required this.private,
    required this.author,
    required this.listWord,
  });

  // Add a method to toggle the star status
  String getAuther() {
    return author;
  }

  String getTopicName() {
    return topicName;
  }

  factory TopicModel.fromMap(Map<dynamic, dynamic> map) {
    var listWordFromMap = map['listWord'] as List<dynamic>? ?? [];
    List<VocabularyEntry> listWord = listWordFromMap
        .map((entry) => VocabularyEntry.fromMap(entry as Map<dynamic, dynamic>))
        .toList();

    return TopicModel(
      category: map['category'] ?? '',
      topicName: map['topicName'] ?? '',
      private: map['private'] ?? false,
      author: map['author'] ?? '',
      listWord: listWord,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'topicName': topicName,
      'private': private,
      'author': author,
      'listWord': listWord.map((entry) => entry.toMap()).toList(),
    };
  }
}
