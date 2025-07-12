import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/controllers/auth_controller.dart';
import 'app/routes/app_routes.dart';
import 'app/views/auth/login_view.dart';
import 'app/views/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SweetHogs Capstone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        primaryColor: Color(0xff0098B9),
        primaryColorLight: Color(0xff0098B9),
        primaryTextTheme: TextTheme(bodyLarge: TextStyle(color: Colors.white)),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff0098B9),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(Color(0xff0098B9)),
          checkColor: WidgetStateProperty.all(Colors.white),
          side: BorderSide(color: Colors.white, width: 1.5),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xff0098B9), width: 1.5),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
      initialRoute: authController.isLoggedIn
          ? AppRoutes.home
          : AppRoutes.login,
      getPages: [
        GetPage(name: AppRoutes.login, page: () => LoginView()),
        GetPage(name: AppRoutes.home, page: () => HomeView()),
        // Add more pages/routes as needed
      ],
    );
  }
}
