import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sweethogs_capstone_frontend/app/controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final width = Get.width;

    return Obx(() {
      if (controller.isLoadingRx.value) {
        return Center(child: CircularProgressIndicator());
      }

      return _buildLoginView(context, width, controller);
    });
  }

  Widget _buildLoginView(
    BuildContext context,
    double width,
    AuthController controller,
  ) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff0098B9), Color(0xffFFFFFF)],
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: width * 0.35,
                padding: EdgeInsets.all(width * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Image.asset(
                        "assets/images/logo_white.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        autocorrect: true,
                        enableSuggestions: true,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
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
                    SizedBox(height: 16),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        obscureText: true,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
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
                    SizedBox(height: 16),
                    //Remember me checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: controller.rememberMeRx.value,
                          onChanged: (value) {
                            if (value != null) {
                              controller.setRememberMe(value);
                            }
                          },
                        ),
                        Text(
                          "Remember me",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 100,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller.login(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              rememberMe: controller.rememberMeRx.value,
                            );
                          },
                          child: Text("Login"),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),

              Image.asset("assets/images/login.png", fit: BoxFit.cover),
            ],
          ),
        ),
      ),
    );
  }
}
