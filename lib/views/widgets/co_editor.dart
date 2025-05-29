import 'package:flutter/material.dart';

class CollabEditor extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final TextStyle? textStyle;
  final Color? cursorColor;
  final Color? selectionColor;

  const CollabEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.textStyle,
    this.cursorColor,
    this.selectionColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      style: textStyle ?? TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
        fontSize: 16,
        fontFamily: 'Montserrat',
      ),
      cursorColor: cursorColor ?? theme.colorScheme.primary,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintStyle: TextStyle(
          color: isDarkMode 
              ? Colors.white.withValues(alpha: 0.5) 
              : Colors.black54,
          fontSize: 16,
          fontFamily: 'Montserrat',
        ),
      ),
      selectionControls: MaterialTextSelectionControls(),
    );
  }
}
