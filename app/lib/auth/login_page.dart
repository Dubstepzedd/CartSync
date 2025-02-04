import 'package:app/backend/server_communicator.dart';
import 'package:app/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // Soft background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),  // Add padding around the form
          child: SizedBox(
            width: 350,  // Increased width for better spacing
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'CartSync',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent, 
                      ),
                    ),
                    const SizedBox(height: 20),
                    getTextFieldIcon('Email', Icons.email, emailController),  
                    const SizedBox(height: 16),
                    getTextFieldIcon('Password', Icons.lock, isSensitive: true, passwordController), 
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: onLogin,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),  
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),  
                        ),
                      ),
                      child: Text('Login', style: TextStyle(fontSize: 18, color: Colors.grey[800])),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          GoRouter.of(context).go('/register');
                        },
                        child: const Text(
                          "Not registered yet? Sign up here.",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onLogin() async {
    // Validate form before proceeding
    if (formKey.currentState!.validate()) {
      try {

        final response = await ServerCommunicator().sendRequest(
          "/login",
          HTTPMethod.post,
          {
            "username": emailController.text.trim(),
            "password": passwordController.text.trim(),
          },
        );

        if(response.containsKey("success") && response["success"] == true) {
          ServerCommunicator().setToken(response["access_token"], response["refresh_token"]);
        }

        if (!mounted) return;

        // Show feedback to the user based on the response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["msg"] ?? "An unknown error occurred",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            backgroundColor: (response["success"] ?? false) ? Colors.greenAccent : Colors.redAccent,
          ),
        );

        // Navigate to home if login is successful
        if (response["success"] == true) {
          GoRouter.of(context).go('/home');
        }
      } catch (e) {
        // Handle errors gracefully and provide feedback
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to login. Please try again.",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[900]),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      } 
    }
  }

}
