import 'package:flutter/foundation.dart';
import '../core/utils/auth_error_util.dart';
import 'auth_service.dart';
import 'attendance_service.dart';
import 'models/staff_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final AttendanceService _attendanceService;
  StaffUser? _staff;
  bool _loading = true;
  String? _error;

  AuthProvider(this._authService, this._attendanceService);

  StaffUser? get staff => _staff;
  bool get isAuthenticated => _staff != null;
  bool get mustChangePassword => _staff?.mustChangePassword ?? false;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> _markAttendanceIfNeeded() async {
    final staff = _staff;
    if (staff == null) return;
    try {
      await _attendanceService.markAttendance(
        staffId: staff.id,
        companyId: staff.companyId,
      );
    } catch (_) {}
  }

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    try {
      if (_authService.isAuthenticated) {
        _staff = await _authService.resolveStaff();
        await _markAttendanceIfNeeded();
      }
    } catch (e) {
      _staff = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String phone, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _staff = await _authService.signInWithPhone(phone, password);
      await _markAttendanceIfNeeded();
      return true;
    } catch (e) {
      _error = formatAuthError(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String newPassword) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.changePassword(newPassword);
      _staff = await _authService.resolveStaff();
      return true;
    } catch (e) {
      _error = formatAuthError(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _staff = null;
    notifyListeners();
  }
}
