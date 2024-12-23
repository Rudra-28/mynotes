import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  print('showErrorDialog called with text: $text');
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("An error occurred"),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              print('Dialog dismissed');
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}