

import 'package:flutter/material.dart';

void displayMessage(BuildContext context, bool isSuccess, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isSuccess ? Colors.greenAccent : Colors.redAccent,
      content: Text(
        message,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 16,
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}