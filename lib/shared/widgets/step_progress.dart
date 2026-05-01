import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class StepProgress extends StatelessWidget {
  const StepProgress({
    required this.currentStep,
    this.totalSteps = 5,
    super.key,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final inactiveTrack = Theme.of(context).colorScheme.outlineVariant;

    return Row(
      children: [
        for (var index = 1; index <= totalSteps; index++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: index == currentStep
                    ? AppColors.primary
                    : index < currentStep
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : inactiveTrack,
                boxShadow: index == currentStep
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          if (index != totalSteps) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
