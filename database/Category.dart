class CategoryModel {
  String nameCategory;
  CategoryModel({
    required this.nameCategory,
  });
  // Phương thức để khởi tạo từ một bản đồ
  factory CategoryModel.fromMap(Map<dynamic, dynamic> map) {
    return CategoryModel(
      nameCategory: map['nameCategory'],
    );
  }
}
