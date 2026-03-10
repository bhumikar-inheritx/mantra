import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_mantra/shared/providers/sankalp_provider.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:deep_mantra/core/theme/app_colors.dart';
import 'package:deep_mantra/core/theme/app_sizes.dart';
import 'package:deep_mantra/localization/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SankalpDialog extends StatefulWidget {
  final Function(int target) onStart;

  const SankalpDialog({super.key, required this.onStart});

  @override
  State<SankalpDialog> createState() => _SankalpDialogState();
}

class _SankalpDialogState extends State<SankalpDialog> {
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muhurta = Provider.of<MuhurtaProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    return Consumer<SankalpProvider>(
      builder: (context, provider, child) {
        bool isCustom = !provider.targets.contains(provider.selectedTarget);
        
        // Update controller only if custom and empty
        if (isCustom && _customController.text.isEmpty && provider.selectedTarget > 0) {
           _customController.text = provider.selectedTarget.toString();
        }

        return AlertDialog(
          backgroundColor: muhurta.isDarkPhase ? AppColors.surfaceDark : AppColors.sandalwoodLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(Icons.wb_sunny_outlined, color: muhurta.accentColor, size: AppSizes.iconXxl),
              ),
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  l10n.translate('set_your_sankalp').toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muhurta.accentColor,
                    fontSize: AppSizes.fontHeading3,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                l10n.translate('repetitions'),
                style: TextStyle(color: muhurta.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: AppSizes.fontSm),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                alignment: WrapAlignment.start,
                children: [
                  ...provider.targets.map((target) {
                    final isSelected = provider.selectedTarget == target;
                    return GestureDetector(
                      onTap: () {
                        provider.setSelectedTarget(target);
                        _customController.clear();
                      },
                      child: Container(
                        width: 50.w,
                        height: 50.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.templeGold : Colors.transparent,
                          border: Border.all(color: AppColors.templeGold.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          target.toString(),
                          style: TextStyle(
                            color: isSelected ? muhurta.onAccentColor : muhurta.primaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.fontBody,
                          ),
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: () {
                      if (!isCustom) {
                        provider.setSelectedTarget(0); // Trigger custom mode
                      }
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCustom ? AppColors.templeGold : Colors.transparent,
                        border: Border.all(color: AppColors.templeGold.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        l10n.translate("custom"),
                        style: TextStyle(
                          color: isCustom ? muhurta.onAccentColor : muhurta.primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.fontXs,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isCustom) ...[
                SizedBox(height: 16.h),
                TextField(
                  controller: _customController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: TextStyle(color: muhurta.primaryTextColor),
                  decoration: InputDecoration(
                    hintText: l10n.translate("enter_custom_count"),
                    hintStyle: TextStyle(color: muhurta.secondaryTextColor.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: muhurta.accentColor.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: const BorderSide(color: AppColors.templeGold),
                    ),
                  ),
                  onChanged: (val) {
                    final count = int.tryParse(val) ?? 0;
                    provider.setSelectedTarget(count);
                  },
                ),
              ],
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (provider.selectedTarget <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.translate("valid_count_error"))),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    widget.onStart(provider.selectedTarget);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: muhurta.accentColor,
                    foregroundColor: muhurta.onAccentColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                  ),
                  child: Text(l10n.translate('ignite_sankalp').toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.fontBody)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
