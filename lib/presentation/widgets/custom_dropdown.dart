import 'package:flutter/material.dart';
import '../../utils/AppColors.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final bool isError; // New: Error state

  const CustomDropdown({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.isError = false, // Default is false
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.secondaryTextColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isError ? Colors.redAccent : AppColors.borderColor, // Red border if error
              width: isError ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isError ? Colors.red : AppColors.borderColor, // Red when error, green otherwise
              width: isError ? 2 : 2,
            ),
          ),
        ),
        value: selectedValue,
        items: options
            .map((option) =>
            DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
        onChanged: (value) {
          onChanged(value);
        },
      ),
    );
  }
}
