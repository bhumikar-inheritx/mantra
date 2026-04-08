import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/alarm_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../localization/app_localizations.dart';

class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onStop() {
    context.read<AlarmProvider>().stopAlarm(widget.alarmSettings.id);
    Navigator.of(context).pop();
  }

  void _onSnooze() async {
    final provider = context.read<AlarmProvider>();
    
    // Stop current alarm
    await provider.stopAlarm(widget.alarmSettings.id);

    // Read the selected mantra and time from provider if needed, or simply duplicate the alarm settings + 5 mins
    final now = DateTime.now();
    final snoozeTime = now.add(const Duration(minutes: 5));
    
    // Create new alarm ID
    final newId = now.millisecondsSinceEpoch % 10000;
    
    // Re-schedule alarm using Service directly or via provider
    // Using provider requires title/body, we can use the original ones if available
    final newSettings = widget.alarmSettings.copyWith(
      id: newId,
      dateTime: snoozeTime,
    );
    await Alarm.set(alarmSettings: newSettings);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Alarm snoozed for 5 minutes.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final timeString = DateFormat('hh:mm').format(now);
    final amPmString = DateFormat('a').format(now);

    return Scaffold(
      backgroundColor: AppColors.cosmicDeep,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                AppColors.templeSaffron.withValues(alpha: 0.3),
                AppColors.cosmicDeep,
              ],
              center: Alignment.center,
              radius: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Title / Message
              Column(
                children: [
                   Icon(
                    Icons.nights_stay,
                    color: AppColors.luxuryGold,
                    size: 48.w,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    widget.alarmSettings.notificationSettings.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.fontHeading2,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.alarmSettings.notificationSettings.body,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: AppSizes.fontTitle,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Time Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    timeString,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 80.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    amPmString,
                    style: TextStyle(
                      color: AppColors.luxuryGold,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Action Buttons
              Column(
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: ElevatedButton(
                      onPressed: _onStop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sacredRed,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 64.w,
                          vertical: 20.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        'Stop',
                        style: TextStyle(
                          fontSize: AppSizes.fontHeading3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  TextButton.icon(
                    onPressed: _onSnooze,
                    icon: Icon(Icons.snooze, color: Colors.white),
                    label: Text(
                      'Snooze',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.fontTitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 16.h,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
