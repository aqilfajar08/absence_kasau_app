// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String imagePath) uploadProfileImage,
    required TResult Function() deleteProfileImage,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String imagePath)? uploadProfileImage,
    TResult? Function()? deleteProfileImage,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String imagePath)? uploadProfileImage,
    TResult Function()? deleteProfileImage,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_UploadProfileImage value) uploadProfileImage,
    required TResult Function(_DeleteProfileImage value) deleteProfileImage,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_UploadProfileImage value)? uploadProfileImage,
    TResult? Function(_DeleteProfileImage value)? deleteProfileImage,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_UploadProfileImage value)? uploadProfileImage,
    TResult Function(_DeleteProfileImage value)? deleteProfileImage,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileEventCopyWith<$Res> {
  factory $ProfileEventCopyWith(
    ProfileEvent value,
    $Res Function(ProfileEvent) then,
  ) = _$ProfileEventCopyWithImpl<$Res, ProfileEvent>;
}

/// @nodoc
class _$ProfileEventCopyWithImpl<$Res, $Val extends ProfileEvent>
    implements $ProfileEventCopyWith<$Res> {
  _$ProfileEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$StartedImplCopyWith<$Res> {
  factory _$$StartedImplCopyWith(
    _$StartedImpl value,
    $Res Function(_$StartedImpl) then,
  ) = __$$StartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StartedImplCopyWithImpl<$Res>
    extends _$ProfileEventCopyWithImpl<$Res, _$StartedImpl>
    implements _$$StartedImplCopyWith<$Res> {
  __$$StartedImplCopyWithImpl(
    _$StartedImpl _value,
    $Res Function(_$StartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$StartedImpl implements _Started {
  const _$StartedImpl();

  @override
  String toString() {
    return 'ProfileEvent.started()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String imagePath) uploadProfileImage,
    required TResult Function() deleteProfileImage,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String imagePath)? uploadProfileImage,
    TResult? Function()? deleteProfileImage,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String imagePath)? uploadProfileImage,
    TResult Function()? deleteProfileImage,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_UploadProfileImage value) uploadProfileImage,
    required TResult Function(_DeleteProfileImage value) deleteProfileImage,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_UploadProfileImage value)? uploadProfileImage,
    TResult? Function(_DeleteProfileImage value)? deleteProfileImage,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_UploadProfileImage value)? uploadProfileImage,
    TResult Function(_DeleteProfileImage value)? deleteProfileImage,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class _Started implements ProfileEvent {
  const factory _Started() = _$StartedImpl;
}

/// @nodoc
abstract class _$$UploadProfileImageImplCopyWith<$Res> {
  factory _$$UploadProfileImageImplCopyWith(
    _$UploadProfileImageImpl value,
    $Res Function(_$UploadProfileImageImpl) then,
  ) = __$$UploadProfileImageImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String imagePath});
}

/// @nodoc
class __$$UploadProfileImageImplCopyWithImpl<$Res>
    extends _$ProfileEventCopyWithImpl<$Res, _$UploadProfileImageImpl>
    implements _$$UploadProfileImageImplCopyWith<$Res> {
  __$$UploadProfileImageImplCopyWithImpl(
    _$UploadProfileImageImpl _value,
    $Res Function(_$UploadProfileImageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? imagePath = null}) {
    return _then(
      _$UploadProfileImageImpl(
        null == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$UploadProfileImageImpl implements _UploadProfileImage {
  const _$UploadProfileImageImpl(this.imagePath);

  @override
  final String imagePath;

  @override
  String toString() {
    return 'ProfileEvent.uploadProfileImage(imagePath: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadProfileImageImpl &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imagePath);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadProfileImageImplCopyWith<_$UploadProfileImageImpl> get copyWith =>
      __$$UploadProfileImageImplCopyWithImpl<_$UploadProfileImageImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String imagePath) uploadProfileImage,
    required TResult Function() deleteProfileImage,
  }) {
    return uploadProfileImage(imagePath);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String imagePath)? uploadProfileImage,
    TResult? Function()? deleteProfileImage,
  }) {
    return uploadProfileImage?.call(imagePath);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String imagePath)? uploadProfileImage,
    TResult Function()? deleteProfileImage,
    required TResult orElse(),
  }) {
    if (uploadProfileImage != null) {
      return uploadProfileImage(imagePath);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_UploadProfileImage value) uploadProfileImage,
    required TResult Function(_DeleteProfileImage value) deleteProfileImage,
  }) {
    return uploadProfileImage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_UploadProfileImage value)? uploadProfileImage,
    TResult? Function(_DeleteProfileImage value)? deleteProfileImage,
  }) {
    return uploadProfileImage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_UploadProfileImage value)? uploadProfileImage,
    TResult Function(_DeleteProfileImage value)? deleteProfileImage,
    required TResult orElse(),
  }) {
    if (uploadProfileImage != null) {
      return uploadProfileImage(this);
    }
    return orElse();
  }
}

abstract class _UploadProfileImage implements ProfileEvent {
  const factory _UploadProfileImage(final String imagePath) =
      _$UploadProfileImageImpl;

  String get imagePath;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UploadProfileImageImplCopyWith<_$UploadProfileImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteProfileImageImplCopyWith<$Res> {
  factory _$$DeleteProfileImageImplCopyWith(
    _$DeleteProfileImageImpl value,
    $Res Function(_$DeleteProfileImageImpl) then,
  ) = __$$DeleteProfileImageImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DeleteProfileImageImplCopyWithImpl<$Res>
    extends _$ProfileEventCopyWithImpl<$Res, _$DeleteProfileImageImpl>
    implements _$$DeleteProfileImageImplCopyWith<$Res> {
  __$$DeleteProfileImageImplCopyWithImpl(
    _$DeleteProfileImageImpl _value,
    $Res Function(_$DeleteProfileImageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DeleteProfileImageImpl implements _DeleteProfileImage {
  const _$DeleteProfileImageImpl();

  @override
  String toString() {
    return 'ProfileEvent.deleteProfileImage()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DeleteProfileImageImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String imagePath) uploadProfileImage,
    required TResult Function() deleteProfileImage,
  }) {
    return deleteProfileImage();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String imagePath)? uploadProfileImage,
    TResult? Function()? deleteProfileImage,
  }) {
    return deleteProfileImage?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String imagePath)? uploadProfileImage,
    TResult Function()? deleteProfileImage,
    required TResult orElse(),
  }) {
    if (deleteProfileImage != null) {
      return deleteProfileImage();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_UploadProfileImage value) uploadProfileImage,
    required TResult Function(_DeleteProfileImage value) deleteProfileImage,
  }) {
    return deleteProfileImage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_UploadProfileImage value)? uploadProfileImage,
    TResult? Function(_DeleteProfileImage value)? deleteProfileImage,
  }) {
    return deleteProfileImage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_UploadProfileImage value)? uploadProfileImage,
    TResult Function(_DeleteProfileImage value)? deleteProfileImage,
    required TResult orElse(),
  }) {
    if (deleteProfileImage != null) {
      return deleteProfileImage(this);
    }
    return orElse();
  }
}

abstract class _DeleteProfileImage implements ProfileEvent {
  const factory _DeleteProfileImage() = _$DeleteProfileImageImpl;
}

/// @nodoc
mixin _$ProfileState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() uploading,
    required TResult Function(User user) uploadSuccess,
    required TResult Function() deleting,
    required TResult Function(User user) deleteSuccess,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? uploading,
    TResult? Function(User user)? uploadSuccess,
    TResult? Function()? deleting,
    TResult? Function(User user)? deleteSuccess,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? uploading,
    TResult Function(User user)? uploadSuccess,
    TResult Function()? deleting,
    TResult Function(User user)? deleteSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_UploadSuccess value) uploadSuccess,
    required TResult Function(_Deleting value) deleting,
    required TResult Function(_DeleteSuccess value) deleteSuccess,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_UploadSuccess value)? uploadSuccess,
    TResult? Function(_Deleting value)? deleting,
    TResult? Function(_DeleteSuccess value)? deleteSuccess,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_UploadSuccess value)? uploadSuccess,
    TResult Function(_Deleting value)? deleting,
    TResult Function(_DeleteSuccess value)? deleteSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
    ProfileState value,
    $Res Function(ProfileState) then,
  ) = _$ProfileStateCopyWithImpl<$Res, ProfileState>;
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res, $Val extends ProfileState>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'ProfileState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() uploading,
    required TResult Function(User user) uploadSuccess,
    required TResult Function() deleting,
    required TResult Function(User user) deleteSuccess,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? uploading,
    TResult? Function(User user)? uploadSuccess,
    TResult? Function()? deleting,
    TResult? Function(User user)? deleteSuccess,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? uploading,
    TResult Function(User user)? uploadSuccess,
    TResult Function()? deleting,
    TResult Function(User user)? deleteSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_UploadSuccess value) uploadSuccess,
    required TResult Function(_Deleting value) deleting,
    required TResult Function(_DeleteSuccess value) deleteSuccess,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_UploadSuccess value)? uploadSuccess,
    TResult? Function(_Deleting value)? deleting,
    TResult? Function(_DeleteSuccess value)? deleteSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_UploadSuccess value)? uploadSuccess,
    TResult Function(_Deleting value)? deleting,
    TResult Function(_DeleteSuccess value)? deleteSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements ProfileState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$UploadingImplCopyWith<$Res> {
  factory _$$UploadingImplCopyWith(
    _$UploadingImpl value,
    $Res Function(_$UploadingImpl) then,
  ) = __$$UploadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UploadingImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$UploadingImpl>
    implements _$$UploadingImplCopyWith<$Res> {
  __$$UploadingImplCopyWithImpl(
    _$UploadingImpl _value,
    $Res Function(_$UploadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UploadingImpl implements _Uploading {
  const _$UploadingImpl();

  @override
  String toString() {
    return 'ProfileState.uploading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UploadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() uploading,
    required TResult Function(User user) uploadSuccess,
    required TResult Function() deleting,
    required TResult Function(User user) deleteSuccess,
    required TResult Function(String message) error,
  }) {
    return uploading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? uploading,
    TResult? Function(User user)? uploadSuccess,
    TResult? Function()? deleting,
    TResult? Function(User user)? deleteSuccess,
    TResult? Function(String message)? error,
  }) {
    return uploading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? uploading,
    TResult Function(User user)? uploadSuccess,
    TResult Function()? deleting,
    TResult Function(User user)? deleteSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (uploading != null) {
      return uploading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_UploadSuccess value) uploadSuccess,
    required TResult Function(_Deleting value) deleting,
    required TResult Function(_DeleteSuccess value) deleteSuccess,
    required TResult Function(_Error value) error,
  }) {
    return uploading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_UploadSuccess value)? uploadSuccess,
    TResult? Function(_Deleting value)? deleting,
    TResult? Function(_DeleteSuccess value)? deleteSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return uploading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_UploadSuccess value)? uploadSuccess,
    TResult Function(_Deleting value)? deleting,
    TResult Function(_DeleteSuccess value)? deleteSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (uploading != null) {
      return uploading(this);
    }
    return orElse();
  }
}

abstract class _Uploading implements ProfileState {
  const factory _Uploading() = _$UploadingImpl;
}

/// @nodoc
abstract class _$$UploadSuccessImplCopyWith<$Res> {
  factory _$$UploadSuccessImplCopyWith(
    _$UploadSuccessImpl value,
    $Res Function(_$UploadSuccessImpl) then,
  ) = __$$UploadSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({User user});
}

/// @nodoc
class __$$UploadSuccessImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$UploadSuccessImpl>
    implements _$$UploadSuccessImplCopyWith<$Res> {
  __$$UploadSuccessImplCopyWithImpl(
    _$UploadSuccessImpl _value,
    $Res Function(_$UploadSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null}) {
    return _then(
      _$UploadSuccessImpl(
        null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                as User,
      ),
    );
  }
}

/// @nodoc

class _$UploadSuccessImpl implements _UploadSuccess {
  const _$UploadSuccessImpl(this.user);

  @override
  final User user;

  @override
  String toString() {
    return 'ProfileState.uploadSuccess(user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadSuccessImpl &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadSuccessImplCopyWith<_$UploadSuccessImpl> get copyWith =>
      __$$UploadSuccessImplCopyWithImpl<_$UploadSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() uploading,
    required TResult Function(User user) uploadSuccess,
    required TResult Function() deleting,
    required TResult Function(User user) deleteSuccess,
    required TResult Function(String message) error,
  }) {
    return uploadSuccess(user);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? uploading,
    TResult? Function(User user)? uploadSuccess,
    TResult? Function()? deleting,
    TResult? Function(User user)? deleteSuccess,
    TResult? Function(String message)? error,
  }) {
    return uploadSuccess?.call(user);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? uploading,
    TResult Function(User user)? uploadSuccess,
    TResult Function()? deleting,
    TResult Function(User user)? deleteSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (uploadSuccess != null) {
      return uploadSuccess(user);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_UploadSuccess value) uploadSuccess,
    required TResult Function(_Deleting value) deleting,
    required TResult Function(_DeleteSuccess value) deleteSuccess,
    required TResult Function(_Error value) error,
  }) {
    return uploadSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_UploadSuccess value)? uploadSuccess,
    TResult? Function(_Deleting value)? deleting,
    TResult? Function(_DeleteSuccess value)? deleteSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return uploadSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_UploadSuccess value)? uploadSuccess,
    TResult Function(_Deleting value)? deleting,
    TResult Function(_DeleteSuccess value)? deleteSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (uploadSuccess != null) {
      return uploadSuccess(this);
    }
    return orElse();
  }
}

abstract class _UploadSuccess implements ProfileState {
  const factory _UploadSuccess(final User user) = _$UploadSuccessImpl;

  User get user;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UploadSuccessImplCopyWith<_$UploadSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeletingImplCopyWith<$Res> {
  factory _$$DeletingImplCopyWith(
    _$DeletingImpl value,
    $Res Function(_$DeletingImpl) then,
  ) = __$$DeletingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DeletingImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$DeletingImpl>
    implements _$$DeletingImplCopyWith<$Res> {
  __$$DeletingImplCopyWithImpl(
    _$DeletingImpl _value,
    $Res Function(_$DeletingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DeletingImpl implements _Deleting {
  const _$DeletingImpl();

  @override
  String toString() {
    return 'ProfileState.deleting()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DeletingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() uploading,
    required TResult Function(User user) uploadSuccess,
    required TResult Function() deleting,
    required TResult Function(User user) deleteSuccess,
    required TResult Function(String message) error,
  }) {
    return deleting();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? uploading,
    TResult? Function(User user)? uploadSuccess,
    TResult? Function()? deleting,
    TResult? Function(User user)? deleteSuccess,
    TResult? Function(String message)? error,
  }) {
    return deleting?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? uploading,
    TResult Function(User user)? uploadSuccess,
    TResult Function()? deleting,
    TResult Function(User user)? deleteSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (deleting != null) {
      return deleting();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_UploadSuccess value) uploadSuccess,
    required TResult Function(_Deleting value) deleting,
    required TResult Function(_DeleteSuccess value) deleteSuccess,
    required TResult Function(_Error value) error,
  }) {
    return deleting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_UploadSuccess value)? uploadSuccess,
    TResult? Function(_Deleting value)? deleting,
    TResult? Function(_DeleteSuccess value)? deleteSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return deleting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_UploadSuccess value)? uploadSuccess,
    TResult Function(_Deleting value)? deleting,
    TResult Function(_DeleteSuccess value)? deleteSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (deleting != null) {
      return deleting(this);
    }
    return orElse();
  }
}

abstract class _Deleting implements ProfileState {
  const factory _Deleting() = _$DeletingImpl;
}

/// @nodoc
abstract class _$$DeleteSuccessImplCopyWith<$Res> {
  factory _$$DeleteSuccessImplCopyWith(
    _$DeleteSuccessImpl value,
    $Res Function(_$DeleteSuccessImpl) then,
  ) = __$$DeleteSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({User user});
}

/// @nodoc
class __$$DeleteSuccessImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$DeleteSuccessImpl>
    implements _$$DeleteSuccessImplCopyWith<$Res> {
  __$$DeleteSuccessImplCopyWithImpl(
    _$DeleteSuccessImpl _value,
    $Res Function(_$DeleteSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null}) {
    return _then(
      _$DeleteSuccessImpl(
        null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                as User,
      ),
    );
  }
}

/// @nodoc

class _$DeleteSuccessImpl implements _DeleteSuccess {
  const _$DeleteSuccessImpl(this.user);

  @override
  final User user;

  @override
  String toString() {
    return 'ProfileState.deleteSuccess(user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteSuccessImpl &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteSuccessImplCopyWith<_$DeleteSuccessImpl> get copyWith =>
      __$$DeleteSuccessImplCopyWithImpl<_$DeleteSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() uploading,
    required TResult Function(User user) uploadSuccess,
    required TResult Function() deleting,
    required TResult Function(User user) deleteSuccess,
    required TResult Function(String message) error,
  }) {
    return deleteSuccess(user);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? uploading,
    TResult? Function(User user)? uploadSuccess,
    TResult? Function()? deleting,
    TResult? Function(User user)? deleteSuccess,
    TResult? Function(String message)? error,
  }) {
    return deleteSuccess?.call(user);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? uploading,
    TResult Function(User user)? uploadSuccess,
    TResult Function()? deleting,
    TResult Function(User user)? deleteSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (deleteSuccess != null) {
      return deleteSuccess(user);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_UploadSuccess value) uploadSuccess,
    required TResult Function(_Deleting value) deleting,
    required TResult Function(_DeleteSuccess value) deleteSuccess,
    required TResult Function(_Error value) error,
  }) {
    return deleteSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_UploadSuccess value)? uploadSuccess,
    TResult? Function(_Deleting value)? deleting,
    TResult? Function(_DeleteSuccess value)? deleteSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return deleteSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_UploadSuccess value)? uploadSuccess,
    TResult Function(_Deleting value)? deleting,
    TResult Function(_DeleteSuccess value)? deleteSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (deleteSuccess != null) {
      return deleteSuccess(this);
    }
    return orElse();
  }
}

abstract class _DeleteSuccess implements ProfileState {
  const factory _DeleteSuccess(final User user) = _$DeleteSuccessImpl;

  User get user;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteSuccessImplCopyWith<_$DeleteSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'ProfileState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() uploading,
    required TResult Function(User user) uploadSuccess,
    required TResult Function() deleting,
    required TResult Function(User user) deleteSuccess,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? uploading,
    TResult? Function(User user)? uploadSuccess,
    TResult? Function()? deleting,
    TResult? Function(User user)? deleteSuccess,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? uploading,
    TResult Function(User user)? uploadSuccess,
    TResult Function()? deleting,
    TResult Function(User user)? deleteSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_UploadSuccess value) uploadSuccess,
    required TResult Function(_Deleting value) deleting,
    required TResult Function(_DeleteSuccess value) deleteSuccess,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_UploadSuccess value)? uploadSuccess,
    TResult? Function(_Deleting value)? deleting,
    TResult? Function(_DeleteSuccess value)? deleteSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_UploadSuccess value)? uploadSuccess,
    TResult Function(_Deleting value)? deleting,
    TResult Function(_DeleteSuccess value)? deleteSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements ProfileState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
