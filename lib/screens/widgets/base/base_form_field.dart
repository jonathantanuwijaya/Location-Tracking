import 'package:flutter/material.dart';
import 'package:tracking_practice/core/constants/app_sizes.dart';

class BaseFormField extends StatelessWidget {
  const BaseFormField({
    required this.controller,
    required this.labelText,
    super.key,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
        ),
        if (validator != null) gapH8,
        if (validator != null)
          Text(
            validator!(controller.text) ?? '',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }
}
