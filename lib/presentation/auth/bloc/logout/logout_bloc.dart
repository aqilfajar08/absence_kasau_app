import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:absence_kasau_app/data/datasources/auth_remote_datasource.dart';
import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';

part 'logout_event.dart';
part 'logout_state.dart';
part 'logout_bloc.freezed.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthRemoteDatasource _authRemoteDatasource;
  LogoutBloc(
    this._authRemoteDatasource,
  ) : super(const _Initial()) {
    on<_Logout>((event, emit) async {
      debugPrint("📩 Event _Logout diterima");
      
      emit(const _Loading());
      
      try {
        // First, try to call the server logout API
        final result = await _authRemoteDatasource.logout();
        
        result.fold(
          (error) {
            // Even if server logout fails, we should still clear local data
            debugPrint("❌ Server logout failed: $error");
            _clearLocalAuthData();
            emit(_Error(error));
          },
          (success) {
            debugPrint("✅ Server logout successful: $success");
            // Clear local authentication data
            _clearLocalAuthData();
            emit(const _Success());
          },
        );
      } catch (e) {
        debugPrint("❌ Exception during logout: $e");
        // Even if there's an exception, clear local data
        _clearLocalAuthData();
        emit(_Error(e.toString()));
      }
    });
  }
  
  // Helper method to clear local authentication data
  void _clearLocalAuthData() {
    try {
      AuthLocalDatasource().removeAuthData();
      debugPrint("🗑️ Local auth data cleared successfully");
    } catch (e) {
      debugPrint("❌ Error clearing local auth data: $e");
    }
  }
}
