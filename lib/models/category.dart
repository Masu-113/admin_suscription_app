class Category {
  final int? id;

  final String name;

  final int? userId;

  Category({this.id, required this.name, this.userId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'user_id': userId};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,

      name: map['name'] as String,

      userId: map['user_id'] as int?,
    );
  }
}
