import 'package:json_annotation/json_annotation.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final LoginUserModel? user; // Make user optional for refresh responses
  final DateTime? expiresAt;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    this.user, // User is now optional
    this.expiresAt,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}

@JsonSerializable()
class LoginUserModel {
  final String id;
  final String email;
  final String role;

  LoginUserModel({required this.id, required this.email, required this.role});

  factory LoginUserModel.fromJson(Map<String, dynamic> json) =>
      _$LoginUserModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginUserModelToJson(this);
}
