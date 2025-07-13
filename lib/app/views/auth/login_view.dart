import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sweethogs_capstone_frontend/app/controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Obx(() {
      if (controller.isLoadingRx.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return _buildLoginView(context, controller);
    });
  }

  Widget _buildLoginView(BuildContext context, AuthController controller) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768 && size.width < 1024;
    final isMobile = size.width < 768;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff0098B9), Color(0xffFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isMobile) {
                return _buildMobileLayout(
                  context,
                  controller,
                  emailController,
                  passwordController,
                  constraints,
                );
              } else if (isTablet) {
                return _buildTabletLayout(
                  context,
                  controller,
                  emailController,
                  passwordController,
                  constraints,
                );
              } else {
                return _buildDesktopLayout(
                  context,
                  controller,
                  emailController,
                  passwordController,
                  constraints,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // Mobile Layout (< 768px)
  Widget _buildMobileLayout(
    BuildContext context,
    AuthController controller,
    TextEditingController emailController,
    TextEditingController passwordController,
    BoxConstraints constraints,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: constraints.maxHeight * 0.1),

          // Logo
          Center(
            child: Container(
              height: 250,
              child: Image.asset(
                "assets/images/logo_white.png",
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Login Form
          _buildLoginForm(
            controller,
            emailController,
            passwordController,
            fieldWidth: double.infinity,
          ),

          const SizedBox(height: 32),

          // Login Image (smaller on mobile)
          Container(
            height: 200,
            child: Image.asset("assets/images/login.png", fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  // Tablet Layout (768px - 1024px)
  Widget _buildTabletLayout(
    BuildContext context,
    AuthController controller,
    TextEditingController emailController,
    TextEditingController passwordController,
    BoxConstraints constraints,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side - Login Form
            Expanded(
              flex: 1,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Container(
                      height: 250,
                      child: Image.asset(
                        "assets/images/logo_white.png",
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Login Form
                    _buildLoginForm(
                      controller,
                      emailController,
                      passwordController,
                      fieldWidth: double.infinity,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 32),

            // Right side - Image
            Expanded(
              flex: 1,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  maxHeight: 400,
                ),
                child: Image.asset(
                  "assets/images/login.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Desktop Layout (>= 1024px)
  Widget _buildDesktopLayout(
    BuildContext context,
    AuthController controller,
    TextEditingController emailController,
    TextEditingController passwordController,
    BoxConstraints constraints,
  ) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side - Login Form
          Container(
            width: constraints.maxWidth * 0.35,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.all(constraints.maxWidth * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Container(
                  height: 250,
                  child: Image.asset(
                    "assets/images/logo_white.png",
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 64),

                // Login Form
                _buildLoginForm(
                  controller,
                  emailController,
                  passwordController,
                  fieldWidth: 350,
                ),
              ],
            ),
          ),

          // Right side - Image
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 600),
              child: Image.asset(
                "assets/images/login.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Login Form Widget
  Widget _buildLoginForm(
    AuthController controller,
    TextEditingController emailController,
    TextEditingController passwordController, {
    required double fieldWidth,
  }) {
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          SizedBox(
            width: fieldWidth == double.infinity ? null : fieldWidth,
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              autocorrect: true,
              enableSuggestions: true,
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                labelText: 'Email',
                focusColor: Colors.white,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                labelStyle: TextStyle(color: Colors.white),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Password Field
          SizedBox(
            width: fieldWidth == double.infinity ? null : fieldWidth,
            child: TextFormField(
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
              },
              obscureText: true,
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                focusColor: Colors.white,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Remember Me Checkbox
          Row(
            children: [
              Obx(
                () => Checkbox(
                  value: controller.rememberMeRx.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setRememberMe(value);
                    }
                  },
                  activeColor: Colors.white,
                  checkColor: const Color(0xff0098B9),
                ),
              ),
              const Text("Remember me", style: TextStyle(color: Colors.white)),
            ],
          ),

          const SizedBox(height: 32),

          // Login Button
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 120,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  // Validate form before attempting login
                  if (formKey.currentState!.validate()) {
                    await controller.login(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      rememberMe: controller.rememberMeRx.value,
                    );
                  } else {
                    // Show validation error message
                    Get.snackbar(
                      'Validation Error',
                      'Please fix the errors above and try again',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xff0098B9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
