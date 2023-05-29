import 'package:flutter/material.dart';

ScaffoldFeatureController showSnack(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text)),
  );
}
