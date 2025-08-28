import 'package:flutter/foundation.dart';
import 'package:absence_kasau_app/data/models/response/auth_response_model.dart';
import 'package:absence_kasau_app/data/models/response/user_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDatasource {
  Future<void> saveAuthData(AuthResponseModel data) async {
    try {
      if (kDebugMode) {
        print('💾 Saving auth data...');
        print('   User: ${data.user?.name}');
        print('   Email: ${data.user?.email}');
        print('   Access Token: ${data.accessToken != null ? "Present" : "Missing"}');
      }

      final pref = await SharedPreferences.getInstance();
      final jsonString = data.toJson();

      if (kDebugMode) {
        print('   JSON Length: ${jsonString.length}');
      }

      final success = await pref.setString('auth_data', jsonString);

      if (kDebugMode) {
        print('   Save Success: $success');
      }

      if (!success) {
        throw Exception('Failed to save auth data to SharedPreferences');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving auth data: $e');
      }
      rethrow;
    }
  }
  
  Future<void> updateAuthData(UserResponseModel data) async {
    final pref = await SharedPreferences.getInstance();
    final authData = await getAuthData();
    if (authData != null) {
      final updateData = authData.copyWith(user: data.user);
      await pref.setString('auth_data', updateData.toJson());
    }
  }

  Future<void> removeAuthData() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('auth_data');
  }

  Future<AuthResponseModel?> getAuthData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final data = pref.getString('auth_data');

      if (kDebugMode) {
        print('📖 Getting auth data...');
        print('   Data exists: ${data != null}');
        if (data != null) {
          print('   Data length: ${data.length}');
        }
      }

      if (data != null) {
        try {
          final authResponse = AuthResponseModel.fromJson(data);

          if (kDebugMode) {
            print('   Parse success: true');
            print('   User: ${authResponse.user?.name}');
            print('   Email: ${authResponse.user?.email}');
            print('   Access Token: ${authResponse.accessToken != null ? "Present" : "Missing"}');
          }

          return authResponse;
        } catch (parseError) {
          if (kDebugMode) {
            print('❌ Error parsing auth data: $parseError');
            print('   Raw data: $data');
          }

          // Clear corrupted data
          await removeAuthData();
          return null;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting auth data: $e');
      }
      return null;
    }
  }

  Future<bool> isAuth() async {
    try {
      final authData = await getAuthData();
      final isAuthenticated = authData != null &&
                             authData.accessToken != null &&
                             authData.accessToken!.isNotEmpty;

      if (kDebugMode) {
        print('🔐 Checking authentication status...');
        print('   Auth data exists: ${authData != null}');
        print('   Access token exists: ${authData?.accessToken != null}');
        print('   Is authenticated: $isAuthenticated');
      }

      return isAuthenticated;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking auth status: $e');
      }
      return false;
    }
  }
}