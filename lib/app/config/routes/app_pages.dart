import '../../features/dashboard/views/screens/dashboard_screen.dart';
import '../../features/login/views/screens/login_screen.dart';
import '../../features/login/bindings/login_binding.dart';
import '../../features/register/views/screens/register_screen.dart';
import '../../features/register/bindings/register_binding.dart';
import '../../features/forgot_password/views/screens/forgot_password_screen.dart';
import '../../features/forgot_password/bindings/forgot_password_binding.dart';
import '../../features/setting/views/screens/setting_screen.dart';
import '../../features/setting/bindings/setting_binding.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: _Paths.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.setting,
      page: () => const SettingScreen(),
      binding: SettingBinding(),
    ),
  ];
}
