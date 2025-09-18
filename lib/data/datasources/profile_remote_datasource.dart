import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:absence_kasau_app/core/constants/variables.dart';
import 'package:absence_kasau_app/data/models/response/profile_response_model.dart';
import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileResponseModel> uploadProfileImage(File imageFile);
  Future<ProfileResponseModel> deleteProfileImage();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final AuthLocalDatasource authLocalDataSource;

  ProfileRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  @override
  Future<ProfileResponseModel> uploadProfileImage(File imageFile) async {
    final authData = await authLocalDataSource.getAuthData();
    final token = authData?.accessToken;
    
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Variables.baseUrl}/api/user/upload-profile-image'),
    );

    // Add authorization header
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    // Add image file
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return ProfileResponseModel.fromJson(response.body);
    } else {
      throw Exception('Failed to upload profile image: ${response.statusCode}');
    }
  }

  @override
  Future<ProfileResponseModel> deleteProfileImage() async {
    final authData = await authLocalDataSource.getAuthData();
    final token = authData?.accessToken;
    
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    final response = await client.delete(
      Uri.parse('${Variables.baseUrl}/api/user/delete-profile-image'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return ProfileResponseModel.fromJson(response.body);
    } else {
      throw Exception('Failed to delete profile image: ${response.statusCode}');
    }
  }
}
