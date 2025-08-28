part of 'add_permission_bloc.dart';

@freezed
class AddPermissionEvent with _$AddPermissionEvent {
  const factory AddPermissionEvent.started() = _Started;
  const factory AddPermissionEvent.addPermission({
    // required String date,
    required String permission,
    required XFile? image,
  }) = _AddPermission;
}