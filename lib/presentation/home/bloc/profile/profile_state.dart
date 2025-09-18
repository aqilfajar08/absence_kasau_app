part of 'profile_bloc.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.uploading() = _Uploading;
  const factory ProfileState.uploadSuccess(User user) = _UploadSuccess;
  const factory ProfileState.deleting() = _Deleting;
  const factory ProfileState.deleteSuccess(User user) = _DeleteSuccess;
  const factory ProfileState.error(String message) = _Error;
}
