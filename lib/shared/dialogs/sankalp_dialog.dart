import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SankalpDialog extends StatefulWidget {
  final Function(String sankalp, int target) onStart;

  const SankalpDialog({super.key, required this.onStart});

  @override
  State<SankalpDialog> createState() => _SankalpDialogState();
}

class _SankalpDialogState extends State<SankalpDialog> {
  String _selectedSankalp = 'Mental Peace';
  int _selectedTarget = 108;

  final List<String> _intentions = [
    'Health',
    'Career',
    'Relationship',
    'Protection',
    'Mental Peace',
    'Spiritual Awakening'
  ];

  final List<int> _targets = [27, 54, 108];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.wb_sunny_outlined, color: AppColors.templeGold, size: 48),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'SET YOUR SANKALP',
                style: TextStyle(
                  color: AppColors.templeGold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Intention',
              style: TextStyle(color: AppColors.mistGrey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _intentions.map((intention) {
                final isSelected = _selectedSankalp == intention;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSankalp = intention),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.templeGold : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.templeGold.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      intention,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.ancientBrown,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Repetitions',
              style: TextStyle(color: AppColors.mistGrey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _targets.map((target) {
                final isSelected = _selectedTarget == target;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTarget = target),
                  child: Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.templeGold : Colors.transparent,
                      border: Border.all(color: AppColors.templeGold.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      target.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.ancientBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onStart(_selectedSankalp, _selectedTarget);
                },
                child: const Text('IGNITE SANKALP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
