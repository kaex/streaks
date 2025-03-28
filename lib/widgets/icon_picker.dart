import 'package:flutter/material.dart';
import '../utils/icon_utils.dart';

class IconPicker extends StatelessWidget {
  final String selectedIconName;
  final Function(String) onIconSelected;

  const IconPicker({
    super.key,
    required this.selectedIconName,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final iconNames = IconUtils.getAllIconNames();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final unselectedIconColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: iconNames.length,
              itemBuilder: (context, index) {
                final iconName = iconNames[index];
                final isSelected = iconName == selectedIconName;

                return GestureDetector(
                  onTap: () => onIconSelected(iconName),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        IconUtils.getIconData(iconName),
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : unselectedIconColor,
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
