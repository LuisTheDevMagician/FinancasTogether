import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String colorHex;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.createdAt,
  });

  // Factory para criar a partir do Map (SQFlite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Converter para Map (SQFlite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // CopyWith para imutabilidade
  User copyWith({
    String? id,
    String? name,
    String? colorHex,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, colorHex, createdAt];

  @override
  String toString() => 'User(id: $id, name: $name, color: $colorHex)';
}
