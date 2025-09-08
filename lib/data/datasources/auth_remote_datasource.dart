import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:absence_kasau_app/core/constants/variables.dart';
import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';
import 'package:absence_kasau_app/data/models/response/auth_response_model.dart';

import '../models/response/user_response_model.dart';

class AuthRemoteDatasource {
  Future<Either<String, AuthResponseModel>> login(
      String username, String password) async {
    final url = Uri.parse('${Variables.baseUrl}/api/login');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return Right(AuthResponseModel.fromJson(response.body));
    } else {
      return const Left('Failed to login');
    }
  }

  //logout
  Future<Either<String, String>> logout() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      
      // If no auth data exists locally, consider logout successful
      if (authData?.accessToken == null) {
        return const Right('Logout success (no local auth data)');
      }
      
      final url = Uri.parse('${Variables.baseUrl}/api/logout');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authData?.accessToken}',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return const Right('Logout success');
      } else if (response.statusCode == 401) {
        // Token is already invalid, consider logout successful
        return const Right('Logout success (token already invalid)');
      } else {
        return Left('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Network error or timeout - still consider logout successful
      // since we'll clear local data anyway
      return const Right('Logout success (network error, local data cleared)');
    }
  }

  Future<Either<String, UserResponseModel>> updateProfileRegisterFace(
    String embedding,
  ) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/user/register-face');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${authData?.accessToken}'
      ..fields['face_embedded'] = embedding;

    final response = await request.send();
    final responseString = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return Right(UserResponseModel.fromJson(responseString));
    } else {
      return const Left('Failed to update profile');
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/user/update-fcm-token');
    await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.accessToken}',
      },
      body: jsonEncode({
        'fcm_token': fcmToken,
      }),
    );
  }
}