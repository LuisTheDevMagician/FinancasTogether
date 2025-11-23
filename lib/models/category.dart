import 'package:equatable/equatable.dart';

enum CategoryType {
  income('INCOME'),
  outcome('OUTCOME'),
  both('BOTH');

  final String value;
  const CategoryType(this.value);

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CategoryType.both,
    );
  }
}

class Category extends Equatable {
  final String id;
  final String name;
  final CategoryType type;
  final String colorHex;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.colorHex,
    required this.createdAt,
  });

  // Factory para criar a partir do Map (SQFlite)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: CategoryType.fromString(map['type'] as String),
      colorHex: map['color_hex'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Converter para Map (SQFlite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'color_hex': colorHex,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // CopyWith para imutabilidade
  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? colorHex,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, type, colorHex, createdAt];

  @override
  String toString() =>
      'Category(id: $id, name: $name, type: ${type.value}, color: $colorHex)';
}
