import 'package:absence_kasau_app/data/datasources/auth_remote_datasource.dart';
import 'package:absence_kasau_app/data/models/response/auth_response_model.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource _authLocalDatasource;
  LoginBloc(
    this._authLocalDatasource,
  ) : super(const _Initial()) {
    on<_Login>((event, emit) async {
      emit(const _Loading());
      final result = await _authLocalDatasource.login(event.email, event.password);
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Success(r)),
      );
    });
  }
}