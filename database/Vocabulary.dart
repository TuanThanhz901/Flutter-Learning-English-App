class VocabularyEntry {
  String english;
  String vietnamese;
  bool star;

  VocabularyEntry(
      {required this.english, required this.vietnamese, this.star = false});

  factory VocabularyEntry.fromMap(Map<dynamic, dynamic> map) {
    return VocabularyEntry(
      english: map['english'] ?? '',
      vietnamese: map['vietnamese'] ?? '',
      star: map['star'] ?? false,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'english': english,
      'vietnamese': vietnamese,
      'star': star,
    };
  }

  // Add a method to toggle the star status
  void toggleStar() {
    star = !star;
  }
}
