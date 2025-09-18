import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:absence_kasau_app/data/datasources/profile_remote_datasource.dart';
import 'package:absence_kasau_app/data/models/response/auth_response_model.dart';
import 'package:absence_kasau_app/core/constants/variables.dart';

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRemoteDataSource profileRemoteDataSource;

  ProfileBloc({
    required this.profileRemoteDataSource,
  }) : super(const ProfileState.initial()) {
    on<_Started>(_onStarted);
    on<_UploadProfileImage>(_onUploadProfileImage);
    on<_DeleteProfileImage>(_onDeleteProfileImage);
  }

  void _onStarted(_Started event, Emitter<ProfileState> emit) {
    emit(const ProfileState.initial());
  }

  Future<void> _onUploadProfileImage(_UploadProfileImage event, Emitter<ProfileState> emit) async {
    emit(const ProfileState.uploading());
    
    try {
      final imageFile = File(event.imagePath);
      final response = await profileRemoteDataSource.uploadProfileImage(imageFile);
      
      print('=== UPLOAD RESPONSE DEBUG ===');
      print('Response status: ${response.status}');
      print('Response message: ${response.message}');
      print('Response imageUrl: ${response.imageUrl}');
      print('Response user: ${response.user}');
      print('Response user imageUrl: ${response.user?.imageUrl}');
      print('=============================');
      
      if (response.status == 'success' && response.user != null) {
        // Fix the image URL by combining with base URL if it's a relative path
        User updatedUser = response.user!;
        if (updatedUser.imageUrl != null && updatedUser.imageUrl.toString().startsWith('/')) {
          // Use the helper method to construct the full URL
          final fullImageUrl = Variables.getImageUrl(updatedUser.imageUrl.toString());
          print('Constructed full image URL: $fullImageUrl');
          updatedUser = User(
            id: updatedUser.id,
            name: updatedUser.name,
            position: updatedUser.position,
            department: updatedUser.department,
            faceEmbedding: updatedUser.faceEmbedding,
            imageUrl: fullImageUrl,
            email: updatedUser.email,
            emailVerifiedAt: updatedUser.emailVerifiedAt,
            twoFactorSecret: updatedUser.twoFactorSecret,
            twoFactorRecoveryCodes: updatedUser.twoFactorRecoveryCodes,
            twoFactorConfirmedAt: updatedUser.twoFactorConfirmedAt,
            createdAt: updatedUser.createdAt,
            updatedAt: updatedUser.updatedAt,
          );
        }
        emit(ProfileState.uploadSuccess(updatedUser));
      } else {
        emit(ProfileState.error(response.message ?? 'Failed to upload profile image'));
      }
    } catch (e) {
      emit(ProfileState.error('Error: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProfileImage(_DeleteProfileImage event, Emitter<ProfileState> emit) async {
    emit(const ProfileState.deleting());
    
    try {
      final response = await profileRemoteDataSource.deleteProfileImage();
      
      if (response.status == 'success' && response.user != null) {
        // Fix the image URL by combining with base URL if it's a relative path
        User updatedUser = response.user!;
        if (updatedUser.imageUrl != null && updatedUser.imageUrl.toString().startsWith('/')) {
          // Use the helper method to construct the full URL
          final fullImageUrl = Variables.getImageUrl(updatedUser.imageUrl.toString());
          print('Constructed full image URL for delete: $fullImageUrl');
          updatedUser = User(
            id: updatedUser.id,
            name: updatedUser.name,
            position: updatedUser.position,
            department: updatedUser.department,
            faceEmbedding: updatedUser.faceEmbedding,
            imageUrl: fullImageUrl,
            email: updatedUser.email,
            emailVerifiedAt: updatedUser.emailVerifiedAt,
            twoFactorSecret: updatedUser.twoFactorSecret,
            twoFactorRecoveryCodes: updatedUser.twoFactorRecoveryCodes,
            twoFactorConfirmedAt: updatedUser.twoFactorConfirmedAt,
            createdAt: updatedUser.createdAt,
            updatedAt: updatedUser.updatedAt,
          );
        }
        emit(ProfileState.deleteSuccess(updatedUser));
      } else {
        emit(ProfileState.error(response.message ?? 'Failed to delete profile image'));
      }
    } catch (e) {
      emit(ProfileState.error('Error: ${e.toString()}'));
    }
  }
}
