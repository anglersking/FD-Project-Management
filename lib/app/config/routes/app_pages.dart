import '../../features/dashboard/views/screens/dashboard_screen.dart';
import '../../features/login/views/screens/login_screen.dart';
import '../../features/login/bindings/login_binding.dart';
import '../../features/register/views/screens/register_screen.dart';
import '../../features/register/bindings/register_binding.dart';
import '../../features/forgot_password/views/screens/forgot_password_screen.dart';
import '../../features/forgot_password/bindings/forgot_password_binding.dart';
import '../../features/setting/views/screens/setting_screen.dart';
import '../../features/setting/bindings/setting_binding.dart';
import '../../features/reports/views/screens/reports_screen.dart';
import '../../features/reports/bindings/reports_binding.dart';
import '../../features/calendar/views/screens/calendar_screen.dart';
import '../../features/calendar/bindings/calendar_binding.dart';
import '../../features/email/views/screens/email_screen.dart';
import '../../features/email/bindings/email_binding.dart';
import '../../features/profile/views/screens/profile_screen.dart';
import '../../features/profile/bindings/profile_binding.dart';
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
    GetPage(
      name: _Paths.reports,
      page: () => const ReportsScreen(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: _Paths.calendar,
      page: () => const CalendarScreen(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: _Paths.email,
      page: () => const EmailScreen(),
      binding: EmailBinding(),
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
  ];
}
