import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'spaces.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Function(String value)? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool showLabel;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.showLabel = true,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.maxLines = 1,
    this.validator,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SpaceHeight(12.0),
        ],
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: maxLines,
          validator: validator,
          textInputAction: textInputAction,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
            ),
            hintText: label,
            hintStyle: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
            ),
            prefixIconColor: AppColors.primary,
            suffixIconColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
