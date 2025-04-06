import 'package:flutter/material.dart';
import '../../utils/AppColors.dart';

class CustomPasswordField extends StatefulWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool isError;

  const CustomPasswordField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isError = false,
    Key? key,
  }) : super(key: key);

  @override
  _CustomPasswordFieldState createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  late TextEditingController _controller;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? "");
  }

  @override
  void didUpdateWidget(covariant CustomPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: AppColors.secondaryBackgroundColor),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.isError ? Colors.redAccent : AppColors.borderColor,
            width: widget.isError ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.isError ? Colors.red : AppColors.borderColor,
            width: widget.isError ? 2 : 2,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      onChanged: (value) {
        widget.onChanged(value);
        if (widget.isError) {
          setState(() {}); // Force rebuild to remove red border
        }
      },
    );
  }
}
