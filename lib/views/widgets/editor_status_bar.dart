import 'package:flutter/material.dart';

class EditorStatusBar extends StatelessWidget {
  final bool hasUnsavedChanges;
  final String statusMessage;
  final String userId;
  final bool hasFocus;

  const EditorStatusBar({
    super.key,
    required this.hasUnsavedChanges,
    required this.statusMessage,
    required this.userId,
    required this.hasFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          if (hasUnsavedChanges) ...[
            const Icon(
              Icons.circle,
              size: 8,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
          ],
          if (statusMessage.isNotEmpty) ...[
            if (hasUnsavedChanges) const SizedBox(width: 16),
            Expanded(
              child: Text(
                statusMessage,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (!hasUnsavedChanges && statusMessage.isEmpty) ...[
            const Icon(
              Icons.check_circle,
              size: 12,
              color: Colors.green,
            ),
            const SizedBox(width: 6),
            Text(
              'Synced',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green[700],
              ),
            ),
          ],
        ],
      ),
    );
  }
}