import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected 
              ? selectedTextColor ?? theme.colorScheme.onPrimary
              : unselectedTextColor ?? theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: unselectedColor ?? theme.colorScheme.surface,
      selectedColor: selectedColor ?? theme.primaryColor,
      checkmarkColor: selectedTextColor ?? theme.colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected 
              ? selectedColor ?? theme.primaryColor 
              : theme.dividerColor,
          width: isSelected ? 0 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      showCheckmark: false,
    );
  }
}
