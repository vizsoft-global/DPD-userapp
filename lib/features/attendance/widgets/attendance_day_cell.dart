import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../attendance_models.dart';

class AttendanceDayCell extends StatelessWidget {
  const AttendanceDayCell({
    required this.dayNumber,
    required this.status,
    this.hourLabel,
    super.key,
  });

  final int dayNumber;
  final DayStatus status;
  final String? hourLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          SizedBox(height: 24, child: Center(child: _statusBadge())),
          const SizedBox(height: 8),
          Text(
            dayNumber.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedLabel,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return switch (status) {
      DayStatus.present => Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.attendancePresentBg,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.attendancePresentBorder,
            width: 0.8,
          ),
        ),
        child: Text(
          hourLabel ?? '0h',
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF141414),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      DayStatus.onlineUnvalidated => Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Text(
          hourLabel ?? '0h',
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF333333),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      DayStatus.absent => const Icon(
        Icons.close_rounded,
        size: 20,
        color: AppColors.tomatoOrange,
      ),
      DayStatus.futureOrInactive => const Text(
        '–',
        style: TextStyle(
          fontSize: 20,
          color: AppColors.mutedLabel,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
    };
  }
}
