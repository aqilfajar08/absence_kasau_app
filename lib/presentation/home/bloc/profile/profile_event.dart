part of 'profile_bloc.dart';

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.started() = _Started;
  const factory ProfileEvent.uploadProfileImage(String imagePath) = _UploadProfileImage;
  const factory ProfileEvent.deleteProfileImage() = _DeleteProfileImage;
}
