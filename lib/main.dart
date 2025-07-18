import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/controllers/auth_controller.dart';
import 'app/routes/app_routes.dart';
import 'app/views/auth/login_view.dart';
import 'app/views/home/home_view.dart';
import 'app/views/patients/patients_view.dart';
import 'app/views/patients/patient_form_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize AuthController
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
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
      home: _buildInitialRoute(),
      getPages: [
        GetPage(name: AppRoutes.login, page: () => LoginView()),
        GetPage(name: AppRoutes.home, page: () => HomeView()),
        GetPage(name: AppRoutes.patients, page: () => PatientsView()),
        GetPage(name: AppRoutes.patientForm, page: () => PatientFormView()),
        // Add more pages/routes as needed
      ],
    );
  }

  Widget _buildInitialRoute() {
    return GetBuilder<AuthController>(
      builder: (authController) {
        print('🏠 Building initial route - isLoading: ${authController.isLoading}, isLoggedIn: ${authController.isLoggedIn}');
        
        if (authController.isLoading) {
          // Show loading screen while checking authentication
          return Scaffold(
            backgroundColor: Color(0xff0098B9),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SweetHogs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Medical Dashboard',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          );
        }

        // Once authentication check is complete, navigate to appropriate screen
        print('🏠 Auth check complete - routing to: ${authController.isLoggedIn ? 'HomeView' : 'LoginView'}');
        return authController.isLoggedIn ? HomeView() : LoginView();
      },
    );
  }
}
