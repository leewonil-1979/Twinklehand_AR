import 'package:flutter/material.dart';
import '../models/app_icon.dart';
import '../utils/app_colors.dart';

/// 아이콘 선택 그리드 위젯
/// 더러운/깨끗한 모드에 따라 해당하는 아이콘들을 그리드로 표시
class IconSelector extends StatelessWidget {
  final List<AppIcon> icons;
  final AppIcon? selectedIcon;
  final Function(AppIcon) onIconSelected;
  final bool isCleanMode;

  const IconSelector({
    super.key,
    required this.icons,
    required this.selectedIcon,
    required this.onIconSelected,
    required this.isCleanMode,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final iconSize = isSmallScreen ? 32.0 : 40.0;
    final fontSize = isSmallScreen ? 10.0 : 12.0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2줄로 배치
          childAspectRatio: 1.0,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final icon = icons[index];
          final isSelected = selectedIcon == icon;
          
          return GestureDetector(
            onTap: () => onIconSelected(icon),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: isSelected 
                    ? (isCleanMode ? AppColors.cleanPrimary : AppColors.dirtyPrimary)
                    : Colors.transparent,
                  width: 3.0,
                ),
                color: isSelected
                  ? (isCleanMode ? AppColors.cleanAccent : AppColors.dirtyAccent).withValues(alpha: 0.3)
                  : (isCleanMode ? AppColors.cleanBackground : AppColors.dirtyBackground),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: (isCleanMode ? AppColors.cleanPrimary : AppColors.dirtyPrimary).withValues(alpha: 0.3),
                    blurRadius: 6.0,
                    spreadRadius: 1.0,
                  ),
                ] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 아이콘 이미지 (반응형 크기)
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: isCleanMode ? AppColors.cleanIconColor : AppColors.dirtyIconColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      _getIconData(icon.name),
                      color: Colors.white,
                      size: iconSize * 0.6, // 아이콘 크기의 60%
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 아이콘 설명 텍스트 (반응형 텍스트)
                  Text(
                    icon.description,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isCleanMode ? AppColors.cleanIconColor : AppColors.dirtyIconColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// 아이콘 이름에 따른 아이콘 데이터 반환 (임시 구현)
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'bacteria_1':
      case 'bacteria_2':
        return Icons.coronavirus;
      case 'virus_1':
        return Icons.bug_report;
      case 'germs_1':
        return Icons.scatter_plot;
      case 'sparkle_1':
      case 'sparkle_2':
        return Icons.auto_awesome;
      case 'star_1':
        return Icons.star;
      case 'bubble_1':
        return Icons.bubble_chart;
      case 'heart_1':
        return Icons.favorite;
      default:
        return Icons.circle;
    }
  }
}
