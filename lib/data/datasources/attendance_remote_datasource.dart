import 'dart:convert';

import 'package:absence_kasau_app/data/models/response/attendance_response_model.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:absence_kasau_app/core/constants/variables.dart';
import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';
import 'package:absence_kasau_app/data/models/request/checkinout_request_model.dart';
import 'package:absence_kasau_app/data/models/response/checkinout_response_model.dart';
import 'package:absence_kasau_app/data/models/response/company_response_model.dart';

class AttendanceRemoteDatasource {
  Future<Either<String, CompanyResponseModel>> getCompanyProfile() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/show-company');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      return Right(CompanyResponseModel.fromJson(response.body));
    } else {
      return const Left('Failed to fetch company profile');
    }
  }

  Future<Either<String, (bool, bool)>> isCheckin() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      final url = Uri.parse('${Variables.baseUrl}/api/attendances/status');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authData?.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        bool parseBool(dynamic value) {
          if (value is bool) return value;
          if (value is num) return value != 0;
          if (value is String) {
            final lower = value.toLowerCase();
            return lower == 'true' || lower == '1' || lower == 'yes';
          }
          return false;
        }

        // Laravel API returns: status, is_checked_in (bool), optional attendance object
        final bool isCheckedIn = parseBool(decoded['is_checked_in']);
        final bool hasAttendance = decoded is Map && decoded['attendance'] != null;
        // If there is an attendance record and is_checked_in is false, then it is checked out.
        final bool isCheckedOut = hasAttendance && !isCheckedIn;
        return Right((isCheckedIn, isCheckedOut));
      } else {
        return Left('Failed to check attendance status: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Failed to check attendance status: $e');
    }
  }

  Future<Either<String, CheckInOutResponseModel>> checkin(
    CheckInOutRequestModel data) async {
      final authData = await AuthLocalDatasource().getAuthData();
      final url = Uri.parse('${Variables.baseUrl}/api/attendances/checkin');

      print('🔍 Checkin API Call:');
      print('   URL: $url');
      print('   Data: ${data.toJson()}');
      print('   Auth Token: ${authData?.accessToken != null ? "Present" : "Missing"}');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authData?.accessToken}',
        },
        body: data.toJson(),
      );

      print('🔍 Checkin Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Checkin Success - Status: ${response.statusCode}');
        return Right(CheckInOutResponseModel.fromJson(response.body));
      } else {
        print('❌ Checkin Failed - Status: ${response.statusCode}');
        return Left('Failed to checkin: ${response.statusCode} - ${response.body}');
      }
    }

  Future<Either<String, CheckInOutResponseModel>> checkout(
      CheckInOutRequestModel data) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/attendances/checkout');

    print('🔍 Checkout API Call:');
    print('   URL: $url');
    print('   Data: ${data.toJson()}');
    print('   Auth Token: ${authData?.accessToken != null ? "Present" : "Missing"}');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.accessToken}',
      },
      body: data.toJson(),
    );

    print('🔍 Checkout Response:');
    print('   Status Code: ${response.statusCode}');
    print('   Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Checkout Success - Status: ${response.statusCode}');
      return Right(CheckInOutResponseModel.fromJson(response.body));
    } else {
      print('❌ Checkout Failed - Status: ${response.statusCode}');
      return Left('Failed to checkout: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Either<String, AttendanceResponseModel>> getAttendance(String date) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/api-attendances?date=$date');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      return Right(AttendanceResponseModel.fromJson(response.body));
    } else {
      return Left('Failed to get attendance: ${response.statusCode} - ${response.body}');
    }
  }
}