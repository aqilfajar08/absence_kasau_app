import 'dart:convert';

class AuthResponseModel {
    final String? message;
    final String? accessToken;
    final User? user;

    AuthResponseModel({
        this.message,
        this.accessToken,
        this.user,
    });

    factory AuthResponseModel.fromJson(String str) => AuthResponseModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory AuthResponseModel.fromMap(Map<String, dynamic> json) => AuthResponseModel(
        message: json["message"],
        accessToken: json["access_token"],
        user: json["user"] == null ? null : User.fromMap(json["user"]),
    );

    Map<String, dynamic> toMap() => {
        "message": message,
        "access_token": accessToken,
        "user": user?.toMap(),
    };

    AuthResponseModel copyWith({
        String? message,
        String? accessToken,
        User? user,
    }) {
        return AuthResponseModel(
            message: message ?? this.message,
            accessToken: accessToken ?? this.accessToken,
            user: user ?? this.user,
        );
    }
}

class User {
    final int? id;
    final String? name;
    final String? position;
    final String? department;
    final String? faceEmbedding;
    final dynamic imageUrl;
    final String? email;
    final DateTime? emailVerifiedAt;
    final dynamic twoFactorSecret;
    final dynamic twoFactorRecoveryCodes;
    final dynamic twoFactorConfirmedAt;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    User({
        this.id,
        this.name,
        this.position,
        this.department,
        this.faceEmbedding,
        this.imageUrl,
        this.email,
        this.emailVerifiedAt,
        this.twoFactorSecret,
        this.twoFactorRecoveryCodes,
        this.twoFactorConfirmedAt,
        this.createdAt,
        this.updatedAt,
    });

    factory User.fromJson(String str) => User.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        position: json["position"],
        department: json["department"],
        faceEmbedding: json["face_embedded"] ?? json["face_embedded"], // Fixed: Handle both possible field names
        imageUrl: json["image_url"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"] == null ? null : DateTime.parse(json["email_verified_at"]),
        twoFactorSecret: json["two_factor_secret"],
        twoFactorRecoveryCodes: json["two_factor_recovery_codes"],
        twoFactorConfirmedAt: json["two_factor_confirmed_at"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "position": position,
        "department": department,
        "face_embedded": faceEmbedding,
        "image_url": imageUrl,
        "email": email,
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "two_factor_secret": twoFactorSecret,
        "two_factor_recovery_codes": twoFactorRecoveryCodes,
        "two_factor_confirmed_at": twoFactorConfirmedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
