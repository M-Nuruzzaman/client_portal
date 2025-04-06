import 'package:client_portal/presentation/screens/settings/settingsScreen.dart';
import 'package:flutter/material.dart';

import '../../../utils/AppColors.dart';
import '../auth/login_screen.dart';
import '../auth/registration_screen.dart';
import '../registration/investor_code_screen.dart';
import 'home_screen.dart';

class DrawerWidget extends StatelessWidget {
  final Function(Widget) navigateToScreen;

  const DrawerWidget({super.key, required this.navigateToScreen});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListTileTheme(
        textColor: Colors.white,
        iconColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primaryColor, size: 50),
            ),
            const SizedBox(height: 16),
            const Text("User Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 30),
            ListTile(
              onTap: () => navigateToScreen(const SettingsScreen()),
              leading: const Icon(Icons.settings),
              title: const Text('Setting'),
            ),
            ListTile(
              onTap: () => navigateToScreen(const RegistrationScreen()),
              leading: const Icon(Icons.app_registration),
              title: const Text('Open Account'),
            ),
            ListTile(
              onTap: () => navigateToScreen(const LoginScreen()),
              leading: const Icon(Icons.login),
              title: const Text('Login'),
            ),
            ListTile(
              onTap: () => navigateToScreen(const InvestorCodeScreen()),
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('BO Account'),
            ),
            const Spacer(),
            ListTile(
              onTap: () => Navigator.of(context).pop(), // Close drawer
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
