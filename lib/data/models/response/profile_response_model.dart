import 'dart:convert';
import 'auth_response_model.dart';

class ProfileResponseModel {
  final String? status;
  final String? message;
  final String? imageUrl;
  final User? user;

  ProfileResponseModel({
    this.status,
    this.message,
    this.imageUrl,
    this.user,
  });

  factory ProfileResponseModel.fromJson(String str) => 
      ProfileResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProfileResponseModel.fromMap(Map<String, dynamic> json) => 
      ProfileResponseModel(
        status: json["status"],
        message: json["message"],
        imageUrl: json["image_url"],
        user: json["user"] == null ? null : User.fromMap(json["user"]),
      );

  Map<String, dynamic> toMap() => {
    "status": status,
    "message": message,
    "image_url": imageUrl,
    "user": user?.toMap(),
  };

  ProfileResponseModel copyWith({
    String? status,
    String? message,
    String? imageUrl,
    User? user,
  }) {
    return ProfileResponseModel(
      status: status ?? this.status,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      user: user ?? this.user,
    );
  }
}

