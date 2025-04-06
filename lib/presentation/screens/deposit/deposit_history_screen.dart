import 'dart:convert';
import 'dart:developer';

import 'package:client_portal/utils/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/api_config.dart';
import '../../../core/utils/api_service_with_file.dart';
import '../../../data/models/Deposit.dart';
import '../../../utils/GradiantBackground.dart';
import '../../../utils/session_manager.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/custom_notification_bar.dart';
import '../withdraw/withdraw_history_screen.dart';

enum DepositFilter { all, online, offline }

class DepositsScreen extends StatefulWidget {
  const DepositsScreen({super.key});

  @override
  State<DepositsScreen> createState() => _DepositsScreenState();
}

class _DepositsScreenState extends State<DepositsScreen> {
  List<Deposit> allDeposits = [];
  DepositFilter selectedFilter = DepositFilter.all;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllDeposits();
  }

  Future<void> _loadAllDeposits() async {
    setState(() => _isLoading = true);

    try {
      String mobileNumber = SessionManager.getMobileNumber() ?? "01705942721";

      log("Calling API: POST deposits/investor?mobileNumber=$mobileNumber", name: "API_CALL");

      final apiService = ApiServiceWithFile();
      final response = await apiService.apiCall(
        endpoint: "deposits/investor?mobileNumber=$mobileNumber",
        baseUrl: ApiConfig.baseUrlTransactionService,
        method: "GET",
      );

      log("Response from deposits/investor?mobileNumber=$mobileNumber: ${response.content}", name: "API_RESPONSE");

      if (response.hasError) {
        showCustomNotification(context, response.message, Colors.red);
      } else {
        if (response.content != "null") {
          final List<dynamic> jsonData = json.decode(response.content!);
          setState(() {
            allDeposits = jsonData.map((e) => Deposit.fromJson(e)).toList();
          });
        } else {
          showCustomNotification(context, response.message, Colors.green);
        }
      }
    } catch (e) {
      showCustomNotification(context, "Error: ${e.toString()}", Colors.red);
    }

    setState(() => _isLoading = false);
  }

  List<Deposit> get _filteredDeposits {
    switch (selectedFilter) {
      case DepositFilter.online:
        return allDeposits.where((d) => d.paymentMethod == 'ONLINE').toList();
      case DepositFilter.offline:
        return allDeposits.where((d) => d.paymentMethod == 'OFFLINE').toList();
      default:
        return allDeposits;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Deposits",
        titleColor: Colors.white,
        onLeadingButtonPressed: () => Navigator.pop(context),
        showBackButton: true,
      ),
      body: GradientBackground(
        child: Stack(
          children: [
            Column(
              children: [
                _buildFilterOptions(),
                Expanded(child: _buildDepositsListView(_filteredDeposits)),
              ],
            ),
            if (_isLoading) const Positioned.fill(child: CustomLoader()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 12, bottom: 5),
      child: Row(
        children: [
          const Text(
            "Filter:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTapDown: (details) async {
              final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

              final selected = await showMenu<DepositFilter>(
                context: context,
                position: RelativeRect.fromRect(
                  details.globalPosition & const Size(40, 40),
                  Offset.zero & overlay.size,
                ),
                color: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 8,
                items: DepositFilter.values.map((filter) {
                  final isSelected = selectedFilter == filter;
                  final label = {
                    DepositFilter.all: 'All',
                    DepositFilter.online: 'Online',
                    DepositFilter.offline: 'Offline',
                  }[filter];

                  return PopupMenuItem<DepositFilter>(
                    value: filter,
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.deepPrimaryColor : Colors.transparent,
                      ),
                      child: Text(
                        label!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );

              if (selected != null) {
                setState(() => selectedFilter = selected);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    {
                      DepositFilter.all: 'All',
                      DepositFilter.online: 'Online',
                      DepositFilter.offline: 'Offline',
                    }[selectedFilter]!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositsListView(List<Deposit> depositsList) {
    if (depositsList.isEmpty) {
      return const Center(child: Text("No deposits found."));
    }

    return ListView.builder(
      itemCount: depositsList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            color: Colors.white10,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: const [
                Expanded(child: Text('Medium', style: headerTextStyle)),
                Expanded(child: Text('Amount', style: headerTextStyle)),
                Expanded(child: Text('Status', style: headerTextStyle)),
                Expanded(child: Text('Time', style: headerTextStyle)),
              ],
            ),
          );
        }

        final deposit = depositsList[index - 1];
        final isDeep = (index % 2 == 0);

        return Container(
          color: isDeep ? Colors.white54 : Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              Expanded(child: Text(deposit.specificChannel ?? deposit.paymentChannel, style: dataTextStyle)),
              Expanded(child: Text('৳${deposit.totalAmount}', style: dataTextStyle)),
              Expanded(child: Text(deposit.status, style: dataTextStyle)),
              Expanded(child: Text(deposit.initiatedOn, style: dataTextStyle)),
            ],
          ),
        );
      },
    );
  }
}
