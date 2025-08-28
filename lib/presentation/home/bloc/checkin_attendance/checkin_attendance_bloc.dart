import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:absence_kasau_app/data/datasources/attendance_remote_datasource.dart';
import 'package:absence_kasau_app/data/models/request/checkinout_request_model.dart';
import 'package:absence_kasau_app/data/models/response/checkinout_response_model.dart';

part 'checkin_attendance_event.dart';
part 'checkin_attendance_state.dart';
part 'checkin_attendance_bloc.freezed.dart';

class CheckinAttendanceBloc extends Bloc<CheckinAttendanceEvent, CheckinAttendanceState> {
  final AttendanceRemoteDatasource datasource;
  CheckinAttendanceBloc(
    this.datasource
  ) : super(const _Initial()) {
    on<_Checkin>((event, emit) async {
      emit(const _Loading());

      // First check if user is already checked in
      print('🔍 CheckinAttendanceBloc: Checking if already checked in...');
      final statusResult = await datasource.isCheckin();

      await statusResult.fold(
        (error) async {
          // If we can't check status, proceed with checkin anyway
          print('⚠️ CheckinAttendanceBloc: Could not check status, proceeding anyway - $error');
          await _performCheckin(event, emit);
        },
        (data) async {
          if (data.$1) {
            // User is already checked in
            print('❌ CheckinAttendanceBloc: User already checked in');
            emit(const _Error('Anda sudah melakukan check-in hari ini'));
          } else {
            // User is not checked in, proceed
            print('✅ CheckinAttendanceBloc: User not checked in, proceeding...');
            await _performCheckin(event, emit);
          }
        },
      );
    });
  }

  Future<void> _performCheckin(_Checkin event, Emitter<CheckinAttendanceState> emit) async {
    final requestModel = CheckInOutRequestModel(
      latitude: event.latitude,
      longitude: event.longitude,
    );
    print('🔍 CheckinAttendanceBloc: Starting checkin...');
    final result = await datasource.checkin(requestModel);
    result.fold(
      (l) {
        print('❌ CheckinAttendanceBloc: Error - $l');
        emit(_Error(l));
      },
      (r) {
        print('✅ CheckinAttendanceBloc: Success - ${r.status}: ${r.message}');
        emit(_Loaded(r));
      },
    );
  }
}
