import 'package:absence_kasau_app/data/datasources/auth_remote_datasource.dart';
import 'package:absence_kasau_app/data/models/response/auth_response_model.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource _authRemoteDatasource;
  LoginBloc(
    this._authRemoteDatasource,
  ) : super(const _Initial()) {
    on<_Login>((event, emit) async {
      if (kDebugMode) {
        print('🚀 LoginBloc: Starting login process...');
        print('📧 Email: ${event.email}');
        print('🔑 Password provided: ${event.password.isNotEmpty}');
      }
      
      emit(const _Loading());
      
      try {
        final result = await _authRemoteDatasource.login(event.email, event.password);
        result.fold(
          (error) {
            if (kDebugMode) {
              print('❌ LoginBloc: Login failed');
              print('   Error: $error');
            }
            emit(_Error(error));
          },
          (success) {
            if (kDebugMode) {
              print('✅ LoginBloc: Login successful');
              print('   User: ${success.user?.name}');
              print('   Token: ${success.accessToken != null ? "Present" : "Missing"}');
            }
            emit(_Success(success));
          },
        );
      } catch (e) {
        if (kDebugMode) {
          print('❌ LoginBloc: Unexpected error during login');
          print('   Error: $e');
        }
        emit(_Error('Unexpected error: ${e.toString()}'));
      }
    });
  }
}