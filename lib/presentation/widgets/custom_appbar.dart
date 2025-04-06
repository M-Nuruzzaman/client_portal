import 'package:client_portal/utils/AppColors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLeadingButtonPressed;
  final bool showBackButton;
  final Color titleColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onLeadingButtonPressed,
    this.showBackButton = true,
    this.titleColor = Colors.white,
    this.elevation = 0.0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: titleColor)),
      centerTitle: true,
      backgroundColor: AppColors.gradiant,
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onLeadingButtonPressed ?? () => Navigator.pop(context),
      )
          : null,
    );
  }
}
