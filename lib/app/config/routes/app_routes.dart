part of 'app_pages.dart';

/// used to switch pages
class Routes {
  static const login = _Paths.login;
  static const register = _Paths.register;
  static const forgotPassword = _Paths.forgotPassword;
  static const dashboard = _Paths.dashboard;
  static const setting = _Paths.setting;
}

/// contains a list of route names.
class _Paths {
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const dashboard = '/dashboard';
  static const setting = '/setting';
}
