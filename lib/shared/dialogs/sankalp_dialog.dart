import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_mantra/shared/providers/sankalp_provider.dart';
import 'package:deep_mantra/shared/providers/muhurta_provider.dart';
import 'package:deep_mantra/core/theme/app_colors.dart';

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
    return Consumer<SankalpProvider>(
      builder: (context, provider, child) {
        bool isCustom = !provider.targets.contains(provider.selectedTarget);
        
        // Update controller only if custom and empty
        if (isCustom && _customController.text.isEmpty && provider.selectedTarget > 0) {
           _customController.text = provider.selectedTarget.toString();
        }

        return Dialog(
          backgroundColor: muhurta.isDarkPhase ? AppColors.surfaceDark : AppColors.sandalwoodLight,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(Icons.wb_sunny_outlined, color: muhurta.accentColor, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'SET YOUR SANKALP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: muhurta.accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Repetitions',
                    style: TextStyle(color: muhurta.secondaryTextColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
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
                            width: 50,
                            height: 50,
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
                                fontSize: 14,
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
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCustom ? AppColors.templeGold : Colors.transparent,
                            border: Border.all(color: AppColors.templeGold.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            "Custom",
                            style: TextStyle(
                              color: isCustom ? muhurta.onAccentColor : muhurta.primaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isCustom) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: TextStyle(color: muhurta.primaryTextColor),
                      decoration: InputDecoration(
                        hintText: "Enter custom count",
                        hintStyle: TextStyle(color: muhurta.secondaryTextColor.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: muhurta.accentColor.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.templeGold),
                        ),
                      ),
                      onChanged: (val) {
                        final count = int.tryParse(val) ?? 0;
                        provider.setSelectedTarget(count);
                      },
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                         if (provider.selectedTarget <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter a valid count")),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        widget.onStart(provider.selectedTarget);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: muhurta.accentColor,
                        foregroundColor: muhurta.onAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('IGNITE SANKALP'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
