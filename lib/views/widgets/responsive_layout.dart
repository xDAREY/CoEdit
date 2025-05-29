import 'package:co_edit/views/widgets/editor_panel.dart';
import 'package:flutter/material.dart';

class ResponsiveEditorLayout extends StatelessWidget {
  final bool isWideScreen;

  const ResponsiveEditorLayout({
    super.key,
    required this.isWideScreen,
  });

  @override
  Widget build(BuildContext context) {
    const sharedDocumentId = 'shared_collaborative_doc';
    
    if (isWideScreen) {
      return Row(
        children: [
          Expanded(
            child: EditorPanel(
              documentId: sharedDocumentId,
              editorId: 'user1',
              title: 'Editor 1 (User 1)',
              userId: 'user1',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: EditorPanel(
              documentId: sharedDocumentId,
              editorId: 'user2',
              title: 'Editor 2 (User 2)',
              userId: 'user2',
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: EditorPanel(
              documentId: sharedDocumentId,
              editorId: 'user1',
              title: 'User 1',
              userId: 'user1',
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: EditorPanel(
              documentId: sharedDocumentId,
              editorId: 'user2',
              title: 'User 2',
              userId: 'user2',
            ),
          ),
        ],
      );
    }
  }
}