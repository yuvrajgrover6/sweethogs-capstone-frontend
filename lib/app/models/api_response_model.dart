import 'package:json_annotation/json_annotation.dart';

part 'api_response_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponseModel<T> {
  final int code;
  final String message;
  final T? body;

  ApiResponseModel({required this.code, required this.message, this.body});

  // Helper property to check if response is successful
  bool get success => code >= 200 && code < 300;

  // Helper property for backward compatibility
  T? get data => body;

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      _$ApiResponseModelToJson(this, toJsonT);
}

@JsonSerializable()
class ErrorResponseModel {
  final bool success;
  final String message;
  final String? error;
  final int? statusCode;
  final DateTime? timestamp;

  ErrorResponseModel({
    required this.success,
    required this.message,
    this.error,
    this.statusCode,
    this.timestamp,
  });

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseModelToJson(this);
}
