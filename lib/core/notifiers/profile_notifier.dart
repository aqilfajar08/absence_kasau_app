import 'package:flutter/foundation.dart';
import 'package:absence_kasau_app/data/models/response/auth_response_model.dart';

class ProfileNotifier extends ChangeNotifier {
  static final ProfileNotifier _instance = ProfileNotifier._internal();
  factory ProfileNotifier() => _instance;
  ProfileNotifier._internal();

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  void setUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void updateProfileImage(String? imageUrl) {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        position: _currentUser!.position,
        department: _currentUser!.department,
        faceEmbedding: _currentUser!.faceEmbedding,
        imageUrl: imageUrl,
        email: _currentUser!.email,
        emailVerifiedAt: _currentUser!.emailVerifiedAt,
        twoFactorSecret: _currentUser!.twoFactorSecret,
        twoFactorRecoveryCodes: _currentUser!.twoFactorRecoveryCodes,
        twoFactorConfirmedAt: _currentUser!.twoFactorConfirmedAt,
        createdAt: _currentUser!.createdAt,
        updatedAt: _currentUser!.updatedAt,
      );
      notifyListeners();
    }
  }

  void clearProfileImage() {
    updateProfileImage(null);
  }
}
