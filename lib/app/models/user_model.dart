import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: '_id')
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  @JsonKey(name: '__v')
  final int version;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.phoneNumber,
    this.dateOfBirth,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  // Computed property for full name
  String get fullName {
    final first = firstName.trim();
    final last = lastName.trim();
    if (first.isEmpty && last.isEmpty) return 'User';
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    return '$first $last';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
