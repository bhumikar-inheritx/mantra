import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/mantra_provider.dart';
import '../widgets/mantra_card.dart';

class MantraListScreen extends StatefulWidget {
  const MantraListScreen({super.key});

  @override
  State<MantraListScreen> createState() => _MantraListScreenState();
}

class _MantraListScreenState extends State<MantraListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<MantraProvider>().loadMantras(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mantraProvider = Provider.of<MantraProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('explore_mantras')),
      ),
      body: Column(
        children: [
          // Category Selector
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mantraProvider.categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final category = mantraProvider.categories[index];
                final isSelected = mantraProvider.selectedCategory == category;
                return GestureDetector(
                  onTap: () => mantraProvider.setCategory(category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.templeSaffron : AppColors.sandalwoodLight,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.templeGold.withValues(alpha: isSelected ? 1 : 0.2),
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.ancientBrown,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Mantra List
          Expanded(
            child: mantraProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.templeGold))
                : mantraProvider.errorMessage != null
                    ? Center(child: Text(mantraProvider.errorMessage!))
                    : ListView.builder(
                        itemCount: mantraProvider.mantras.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final mantra = mantraProvider.mantras[index];
                          return MantraCard(mantra: mantra);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
