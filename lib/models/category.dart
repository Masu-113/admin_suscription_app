class Category {
  final int? id;

  final int? cloudId;

  final String name;

  final String? userId;

  Category({this.id, this.cloudId, required this.name, this.userId});

  Category copyWith({
    int? id,
    int? cloudId,
    String? name,
    String? userId,
  }) {
    return Category(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      name: name ?? this.name,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'cloud_id': cloudId, 'name': name, 'user_id': userId};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      name: map['name'] as String,
      userId: map['user_id'] as String?,
    );
  }
}
