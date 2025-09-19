import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/app_state_provider.dart';
import '../../../../providers/ar_effects_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';

class IconSelector extends StatelessWidget {
  const IconSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              // Dirty Icons Row
              _buildIconRow(
                context,
                icons: AppIcons.dirtyIcons.take(6).toList(),
                selectedIcon: appState.selectedDirtyIcon,
                isCleanMode: false,
                currentMode: appState.currentMode,
                onIconSelected: (icon) {
                  appState.selectDirtyIcon(icon);
                  if (appState.currentMode == AppMode.dirty) {
                    _regenerateEffects(context, appState, icon);
                  }
                },
              ),
              const SizedBox(height: 8),
              // Clean Icons Row
              _buildIconRow(
                context,
                icons: AppIcons.cleanIcons.take(6).toList(),
                selectedIcon: appState.selectedCleanIcon,
                isCleanMode: true,
                currentMode: appState.currentMode,
                onIconSelected: (icon) {
                  appState.selectCleanIcon(icon);
                  if (appState.currentMode == AppMode.clean) {
                    _regenerateEffects(context, appState, icon);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildIconRow({
    required BuildContext context,
    required List<String> icons,
    required String selectedIcon,
    required bool isCleanMode,
    required AppMode currentMode,
    required Function(String) onIconSelected,
  }) {
    final isActiveRow = (isCleanMode && currentMode == AppMode.clean) ||
                        (!isCleanMode && currentMode == AppMode.dirty);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: icons.map((icon) {
          final isSelected = icon == selectedIcon && isActiveRow;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onIconSelected(icon);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isCleanMode
                        ? AppColors.cleanMode.withOpacity(0.3)
                        : AppColors.dirtyMode.withOpacity(0.3))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? (isCleanMode ? AppColors.cleanMode : AppColors.dirtyMode)
                      : isActiveRow
                          ? Colors.white30
                          : Colors.white10,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  icon,
                  style: TextStyle(
                    fontSize: 22,
                    shadows: isSelected
                        ? [
                            Shadow(
                              color: isCleanMode
                                  ? AppColors.cleanMode
                                  : AppColors.dirtyMode,
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  void _regenerateEffects(
    BuildContext context,
    AppStateProvider appState,
    String icon,
  ) {
    final arProvider = context.read<AREffectsProvider>();
    arProvider.generateEffects(
      icon: icon,
      count: appState.currentMode == AppMode.clean ? 12 : 20,
      mode: appState.currentMode,
    );
  }
}