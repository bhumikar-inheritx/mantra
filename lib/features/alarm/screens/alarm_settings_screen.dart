import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../localization/app_localizations.dart';
import '../../mantra/providers/mantra_provider.dart';
import '../../../core/providers/alarm_provider.dart';

class AlarmSettingsScreen extends StatelessWidget {
  const AlarmSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alarmProvider = context.watch<AlarmProvider>();
    final mantraProvider = context.watch<MantraProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('set_alarm') ?? 'Set Alarm'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimePicker(context, alarmProvider),
            SizedBox(height: 32.h),
            _buildMantraSelector(context, alarmProvider, mantraProvider, l10n),
            const Spacer(),
            _buildSaveButton(context, alarmProvider, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, AlarmProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(provider.selectedTime),
            );
            if (time != null) {
              final now = DateTime.now();
              provider.setSelectedTime(DateTime(
                now.year,
                now.month,
                now.day,
                time.hour,
                time.minute,
              ));
            }
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.jm().format(provider.selectedTime),
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.access_time),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMantraSelector(
    BuildContext context,
    AlarmProvider alarmProvider,
    MantraProvider mantraProvider,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Mantra',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        Container(
          height: 300.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: mantraProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: mantraProvider.mantras.length,
                  itemBuilder: (context, index) {
                    final mantra = mantraProvider.mantras[index];
                    final isSelected = alarmProvider.selectedMantra?.id == mantra.id;
                    return ListTile(
                      title: Text(mantra.title),
                      subtitle: Text(mantra.category),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                      onTap: () => alarmProvider.setSelectedMantra(mantra),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, AlarmProvider provider, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        onPressed: provider.selectedMantra == null
            ? null
            : () async {
                await provider.scheduleAlarm(
                  title: 'Mantra Reminder',
                  body: 'Time for your ${provider.selectedMantra!.title} practice',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alarm set successfully')),
                  );
                  Navigator.pop(context);
                }
              },
        child: const Text('Save Alarm', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
