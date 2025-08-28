import 'package:absence_kasau_app/data/datasources/attendance_remote_datasource.dart';
import 'package:absence_kasau_app/data/models/request/checkinout_request_model.dart';
import 'package:absence_kasau_app/data/models/response/checkinout_response_model.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_attendance_event.dart';
part 'checkout_attendance_state.dart';
part 'checkout_attendance_bloc.freezed.dart';

class CheckoutAttendanceBloc extends Bloc<CheckoutAttendanceEvent, CheckoutAttendanceState> {
  final AttendanceRemoteDatasource datasource;
  CheckoutAttendanceBloc(
    this.datasource
  ) : super(const _Initial()) {
    on<_Checkout>((event, emit) async {
      emit(const _Loading());
      final requestModel = CheckInOutRequestModel(
        latitude: event.latitude,
        longitude: event.longitude,
      );
      final result = await datasource.checkout(requestModel);
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Loaded(r)),
      );
    });
  }
}