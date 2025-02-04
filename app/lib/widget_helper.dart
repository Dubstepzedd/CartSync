// Reusable method to create a nice text field. 
import 'package:flutter/material.dart';

Widget getTextFieldIcon(String label, IconData icon, TextEditingController controller, {bool isSensitive = false}) {
  return TextField(
    controller: controller,
    obscureText: isSensitive,  
    decoration: InputDecoration(
      hintText: label,
      prefixIcon: Icon(icon), 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
    ),
  );
}

Widget getTextField(String label, TextEditingController controller, {bool isSensitive = false, int maxLines = 1}) {
  return TextField(
    controller: controller,
    obscureText: isSensitive,  
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
    ),
  );
}

