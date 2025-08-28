import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:absence_kasau_app/data/datasources/auth_remote_datasource.dart';

part 'logout_event.dart';
part 'logout_state.dart';
part 'logout_bloc.freezed.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthRemoteDatasource _authRemoteDatasource;
  LogoutBloc(
    this._authRemoteDatasource,
  ) : super(const _Initial()) {
    on<_Logout>((event, emit) async {
      debugPrint("📩 Event _Logout diterima");
      
      emit(const _Loading());
      final result = await _authRemoteDatasource.logout();
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(const _Success()),
      );
    });
  }
}
