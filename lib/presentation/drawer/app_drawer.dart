import 'package:client_portal/presentation/screens/deposit/deposit_history_screen.dart';
import 'package:client_portal/presentation/screens/deposit/fund_deposit_screen.dart';
import 'package:client_portal/presentation/screens/home/home_screen.dart';
import 'package:client_portal/presentation/screens/registration/information_screen.dart';
import 'package:client_portal/presentation/screens/withdraw/fund_withdraw_screen.dart';
import 'package:client_portal/presentation/screens/withdraw/withdraw_history_screen.dart';
import 'package:client_portal/utils/session_manager.dart';
import 'package:flutter/material.dart';
import '../../utils/AppColors.dart';
import '../../utils/custom_page_route.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  Map<String, dynamic> data = {};

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea( // Ensures the drawer starts below the AppBar
        child: Container(
          color: AppColors.backgroundColor, // Set the background color of the drawer
          child: Column(
            children: [
              // Drawer Header with scrollable content to prevent overflow
              DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center, // Center-aligning content
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    // Username Box with full width and responsive behavior
                    Container(
                      width: double.infinity, // Ensures it takes full width
                      padding: EdgeInsets.symmetric(horizontal: 16), // Padding for text inside
                      child: Column(
                        children: [
                          // Responsive Text for Username
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              SessionManager.getMobileNumber() ?? "Pulok Rehan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center, // Center-align text
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(  // Making the content scrollable
                  child: Column(
                    children: [
                      _buildDrawerItem(Icons.home, 'Open New Account', context, '/open-bo-account'),
                      _buildDrawerItem(Icons.person, 'Profile', context, '/profile'),
                      _buildDrawerItem(Icons.money, 'Deposit Funds', context, '/deposit'),
                      _buildDrawerItem(Icons.manage_accounts, 'Deposits', context, '/deposits'),
                      _buildDrawerItem(Icons.money, 'Withdraw Funds', context, '/withdraw'),
                      _buildDrawerItem(Icons.money, 'Withdrawals', context, '/withdraws'),
                      // _buildDrawerItem(Icons.request_page, 'IPO Application', context, '/profile'),
                      // _buildDrawerItem(Icons.pages, 'Reports', context, '/profile'),
                      // _buildDrawerItem(Icons.settings, 'Settings', context, '/settings'),
                      Divider(color: AppColors.secondaryTextColor, thickness: 1),
                      _buildDrawerItem(Icons.logout, 'Logout', context, '/logout', isLogout: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildDrawerItem(IconData icon, String title, BuildContext context, String route, {bool isLogout = false}) {
  //   return InkWell(
  //     onTap: () {
  //       Navigator.pop(context);
  //       if (isLogout) {
  //         // Handle logout logic
  //       } else {
  //         Navigator.pushNamed(context, route);
  //       }
  //     },
  //     child: Container(
  //       color: Colors.transparent,
  //       child: ListTile(
  //         leading: Icon(icon, color: AppColors.primaryColor),
  //         title: Text(
  //           title,
  //           style: TextStyle(
  //             color: AppColors.textColor,
  //             fontSize: 18,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, String route, {bool isLogout = false}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (isLogout) {
          Navigator.push(
            context,
            CustomPageRoute(page: HomeScreen()),
          );
        }
        else if(route == "/open-bo-account"){

          Navigator.push(
            context,
            CustomPageRoute(page: InformationScreen(step: 0, data: data)),
          );
        }
        else if(route == "/deposit"){
          Navigator.push(
            context,
            CustomPageRoute(page: FundDepositScreen()),
          );
        }
        else if(route == "/deposits"){
          Navigator.push(
            context,
            CustomPageRoute(page: DepositsScreen()),
          );
        }
        else if(route == "/withdraw"){
          Navigator.push(
            context,
            CustomPageRoute(page: FundWithdrawScreen()),
          );
        }
        else if(route == "/withdraws"){
          Navigator.push(
            context,
            CustomPageRoute(page: WithdrawHistoryScreen()),
          );
        }
        else if(route == "/logout"){
          Navigator.push(
            context,
            CustomPageRoute(page: HomeScreen()),
          );
        }
      },
      child: Container(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: AppColors.primaryColor),
          title: Text(
            title,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
      ),
    );
  }
}