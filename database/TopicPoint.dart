class TopicPoint {
  String nameTopic;
  int point;

  TopicPoint({
    required this.nameTopic,
    required this.point,
  });
  factory TopicPoint.fromMap(Map<dynamic, dynamic> map) {
    return TopicPoint(
      nameTopic: map['nameTopic'] ?? '',
      point: map['point'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameTopic': nameTopic,
      'point': point,
    };
  }
}
