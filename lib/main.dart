import 'app/config/routes/app_pages.dart';
import 'app/config/themes/app_theme.dart';
import 'app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await AuthService.isLoggedIn();
  runApp(MyApp(initialRoute: isLoggedIn ? Routes.dashboard : Routes.login));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Project Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.basic,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
