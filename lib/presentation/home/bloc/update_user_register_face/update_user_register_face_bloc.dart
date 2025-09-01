import 'package:absence_kasau_app/data/datasources/auth_remote_datasource.dart';
import 'package:absence_kasau_app/data/models/response/user_response_model.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'update_user_register_face_event.dart';
part 'update_user_register_face_state.dart';
part 'update_user_register_face_bloc.freezed.dart';

class UpdateUserRegisterFaceBloc extends Bloc<UpdateUserRegisterFaceEvent, UpdateUserRegisterFaceState> {
  final AuthRemoteDatasource authRemoteDatasource;
  UpdateUserRegisterFaceBloc(
    this.authRemoteDatasource
  ) : super(const _Initial()) {
    on<_UpdateProfileRegisterFace>((event, emit) async {
      if (kDebugMode) {
        print('🚀 UpdateUserRegisterFaceBloc: Starting face registration...');
        print('📊 Embedding length: ${event.embedding.length}');
        print('📊 First 10 values: ${event.embedding.split(',').take(10).toList()}');
      }
      
      emit(const _Loading());
      try {
        final user = await authRemoteDatasource.updateProfileRegisterFace(event.embedding);
        user.fold(
          (error) {
            if (kDebugMode) {
              print('❌ UpdateUserRegisterFaceBloc: Registration failed - $error');
            }
            emit(_Error(error));
          },
          (success) {
            if (kDebugMode) {
              print('✅ UpdateUserRegisterFaceBloc: Registration successful');
              print('📝 User data: ${success.user?.name}');
            }
            emit(_Success(success));
          },
        );
      } catch (e) {
        if (kDebugMode) {
          print('❌ UpdateUserRegisterFaceBloc: Unexpected error - $e');
        }
        emit(_Error(e.toString()));
      }
    });
  }
}
