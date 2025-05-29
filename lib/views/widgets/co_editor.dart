import 'package:flutter/material.dart';

class CollabEditor extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const CollabEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      maxLines: null,
      expands: true,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          color: Colors.grey[600],
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      textAlignVertical: TextAlignVertical.top,
    );
  }
}