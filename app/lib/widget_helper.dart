// Reusable method to create a nice text field. 
import 'package:flutter/material.dart';

// TODO These validators are very simple, let the developer pass in a custom validator

Widget getTextFieldIcon(String label, IconData icon, TextEditingController controller, {bool isSensitive = false}) {
  return TextFormField(
    controller: controller,
    obscureText: isSensitive,  
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please fill in this field';
      }
      return null;
    },
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
  return TextFormField(
    controller: controller,
    obscureText: isSensitive,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please fill in this field';
      }
      return null;
    },
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

