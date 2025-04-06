import 'package:flutter/material.dart';
import '../../utils/AppColors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool isError;

  const CustomTextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isError = false,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? "");
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: AppColors.secondaryTextColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.isError ? Colors.redAccent : AppColors.secondaryBackgroundColor,
              width: widget.isError ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.isError ? Colors.red : AppColors.borderColor,
              width: widget.isError ? 2 : 2,
            ),
          ),
        ),
        onChanged: (value) {
          widget.onChanged(value);
          if (widget.isError) {
            setState(() {}); // Force rebuild to remove red border
          }
        },
      ),
    );
  }
}
