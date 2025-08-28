import 'package:absence_kasau_app/data/datasources/attendance_remote_datasource.dart';
import 'package:absence_kasau_app/presentation/home/models/absence_status.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'is_checkin_event.dart';
part 'is_checkin_state.dart';
part 'is_checkin_bloc.freezed.dart';

class IsCheckinBloc extends Bloc<IsCheckinEvent, IsCheckinState> {
  AttendanceRemoteDatasource datasource;
  IsCheckinBloc(
    this.datasource
  ) : super(const _Initial()) {
    on<_IsCheckIn>((event, emit) async {
        emit(const _Loading());
        final result = await datasource.isCheckin();
        result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Success(AbsenceStatus(
          isCheckIn: r.$1,
          isCheckOut: r.$2,
        ))),
      );
    });
  }
}