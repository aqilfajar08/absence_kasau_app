import 'dart:convert';

class AttendanceResponseModel {
    final String? status;
    final List<Attendance>? data;

    AttendanceResponseModel({
        this.status,
        this.data,
    });

    factory AttendanceResponseModel.fromJson(String str) => AttendanceResponseModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory AttendanceResponseModel.fromMap(Map<String, dynamic> json) => AttendanceResponseModel(
        status: json["status"],
        data: json["data"] == null ? [] : List<Attendance>.from(json["data"]!.map((x) => Attendance.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
    };
}

class Attendance{
    final int? id;
    final int? userId;
    final DateTime? dateAttendance;
    final String? timeIn;
    final String? timeOut;
    final String? latlonIn;
    final String? latlonOut;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    Attendance({
        this.id,
        this.userId,
        this.dateAttendance,
        this.timeIn,
        this.timeOut,
        this.latlonIn,
        this.latlonOut,
        this.createdAt,
        this.updatedAt,
    });

    factory Attendance.fromJson(String str) => Attendance.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Attendance.fromMap(Map<String, dynamic> json) => Attendance(
        id: json["id"],
        userId: json["user_id"],
        dateAttendance: json["date_attendance"] == null ? null : DateTime.parse(json["date_attendance"]),
        timeIn: json["time_in"],
        timeOut: json["time_out"],
        latlonIn: json["latlon_in"],
        latlonOut: json["latlon_out"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userId,
        "date_attendance": "${dateAttendance!.year.toString().padLeft(4, '0')}-${dateAttendance!.month.toString().padLeft(2, '0')}-${dateAttendance!.day.toString().padLeft(2, '0')}",
        "time_in": timeIn,
        "time_out": timeOut,
        "latlon_in": latlonIn,
        "latlon_out": latlonOut,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
