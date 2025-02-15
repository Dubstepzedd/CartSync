import 'package:app/helper.dart';
import 'package:app/pages/providers/app_state.dart';
import 'package:app/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
      backgroundColor: Colors.white,  // Soft background color
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
              color: Colors.grey[300],
              height: 2.0,
          )
        ),
        backgroundColor: Colors.white,
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
                      onPressed: () => onRegister(context),
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
  
  Future<void> onRegister(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final email = emailController.text;
      final password = passwordController.text;
      context.read<AppState>().register(email, password).then((response) {
        if (!context.mounted) {
          return;
        }

        displayMessage(context, response.statusCode == 201, response.message);

        if (response.statusCode == 201) {
          GoRouter.of(context).go('/login');
        }
      });
    }
    else {
      displayMessage(context, false, "Please fill in all fields");
    }
  }
}
