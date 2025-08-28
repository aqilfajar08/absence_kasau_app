part of 'is_checkin_bloc.dart';

@freezed
class IsCheckinState with _$IsCheckinState {
  const factory IsCheckinState.initial() = _Initial;
  const factory IsCheckinState.loading() = _Loading;
  const factory IsCheckinState.success(AbsenceStatus data) = _Success;
  const factory IsCheckinState.error(String message) = _Error;
}
