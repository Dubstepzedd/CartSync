import 'package:app/backend/server_communicator.dart';
import 'package:app/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).replace('/login'),
        ),
      ),
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
                      onPressed: onRegister,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),  
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),  
                        ),
                      ),
                      child: Text('Register', style: TextStyle(fontSize: 18, color: Colors.grey[800])),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  } 
  
  Future<void> onRegister() async {
    if (formKey.currentState!.validate()) {
       try {

        final response = await ServerCommunicator().sendRequest(
          "/register",
          HTTPMethod.post,
          {
            "username": emailController.text.trim(),
            "password": passwordController.text.trim(),
          },
        );

        // Check if the widget is still mounted before interacting with the context
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
          GoRouter.of(context).go('/login');
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
