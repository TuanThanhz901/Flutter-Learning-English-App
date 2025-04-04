import 'package:final_project/database/TopicPoint.dart';

class UserModel {
  String email;
  String name;
  List<TopicPoint> listPoint;

  UserModel({
    required this.email,
    required this.name,
    required this.listPoint,
  });
  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    var listPointFromMap = <TopicPoint>[];
    if (map['listPoint'] != null) {
      listPointFromMap = (map['listPoint'] as List)
          .map((item) => TopicPoint.fromMap(item))
          .toList();
    }
    return UserModel(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      listPoint: listPointFromMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'listPoint': listPoint.map((e) => e.toMap()).toList(),
    };
  }
}
