import 'package:co_edit/controller/editor_controller.dart' as editor_controller;
import 'package:co_edit/state/editor_state.dart';
import 'package:co_edit/state/focus/global_tracker.dart';
import 'package:co_edit/state/providers.dart';
import 'package:co_edit/views/widgets/co_editor.dart';
import 'package:co_edit/views/widgets/editor_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditorPanel extends ConsumerStatefulWidget {
  final String documentId;
  final String editorId;
  final String title;
  final String userId;

  const EditorPanel({
    super.key,
    required this.documentId,
    required this.editorId,
    required this.title,
    required this.userId,
  });

  @override
  ConsumerState<EditorPanel> createState() => _EditorPanelState();
}

class _EditorPanelState extends ConsumerState<EditorPanel> {
  late editor_controller.EditorController _editorController;

  @override
  void initState() {
    super.initState();
    _editorController = editor_controller.EditorController(
      documentId: widget.documentId,
      userId: widget.userId,
    );
  }

  @override
  void dispose() {
    _editorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorStateProvider(widget.documentId));
    
    ref.listen<EditorState>(
      editorStateProvider(widget.documentId),
      (previous, next) {
        _editorController.onStateChanged(previous, next);
      },
    );

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.userId == 'user1' 
            ? const Color(0xFF8B4513) 
            : const Color.fromARGB(255, 111, 82, 3),
        borderRadius: BorderRadius.circular(12),
        border: _editorController.hasFocus
            ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: _buildEditorBody(),
          ),
          if (editorState.hasUnsavedChanges || editorState.statusMessage.isNotEmpty)
            EditorStatusBar(
              hasUnsavedChanges: editorState.hasUnsavedChanges,
              statusMessage: editorState.statusMessage,
              userId: widget.userId,
              hasFocus: _editorController.hasFocus,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            widget.userId == 'user1' ? Icons.person : Icons.person_outline,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<String?>(
            valueListenable: GlobalFocusTracker().activeTypingEditorNotifier,
            builder: (context, activeTypingEditor, _) {
              final shouldShow = activeTypingEditor == _editorController.editorId;
              
              return AnimatedOpacity(
                opacity: shouldShow ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildEditorBody() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8F8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: CollabEditor(
        controller: _editorController.textController,
        focusNode: _editorController.focusNode,
        onChanged: (text) {
          final editorNotifier = ref.watch(
            editorStateProvider(widget.documentId).notifier
          );
          _editorController.onTextChanged(text, editorNotifier);
        },
      ),
    );
  }
}


