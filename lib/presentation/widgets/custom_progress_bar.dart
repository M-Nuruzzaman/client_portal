import 'package:flutter/material.dart';

import '../../utils/AppColors.dart';

class CustomProgressBar {
  static Widget buildStepProgressBar(
      int len, int currentStep, Function(int) onStepTap) {
    return Row(
      children: List.generate(len, (index) {
        return Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                          height: 6,
                          color: currentStep >= index
                              ? AppColors.successColor
                              : AppColors.linkColor
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      onStepTap(index); // Call the passed function
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentStep >= index
                                  ? AppColors.successColor
                                  : AppColors.linkColor,
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: currentStep >= index
                                    ? AppColors.successColor
                                    : AppColors.linkColor,
                                width: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < len - 1)
                    Expanded(
                      child: Container(
                        height: 6,
                        color: currentStep > index
                            ? AppColors.successColor
                            : AppColors.linkColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      }),
    );
  }
}