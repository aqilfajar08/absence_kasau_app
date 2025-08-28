part of 'is_checkin_bloc.dart';

@freezed
class IsCheckinEvent with _$IsCheckinEvent {
  const factory IsCheckinEvent.started() = _Started;
  const factory IsCheckinEvent.isCheckIn() = _IsCheckIn;
}