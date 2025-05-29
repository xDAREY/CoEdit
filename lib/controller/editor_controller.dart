import 'dart:async';
import 'package:co_edit/state/editor_state.dart';
import 'package:co_edit/state/focus/global_tracker.dart';
import 'package:flutter/material.dart';

class EditorController {
  final String documentId;
  final String userId;
  final GlobalFocusTracker _focusTracker = GlobalFocusTracker();
  
  late TextEditingController _textController;
  late FocusNode _focusNode;
  
  bool _isUpdatingFromState = false;
  bool _hasFocus = false;
  
  String get editorId => '${documentId}_$userId';

  EditorController({
    required this.documentId,
    required this.userId,
  }) {
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  // Getters for UI
  TextEditingController get textController => _textController;
  FocusNode get focusNode => _focusNode;
  bool get hasFocus => _hasFocus;

  void _onFocusChange() {
    final previousFocus = _hasFocus;
    _hasFocus = _focusNode.hasFocus;
    
    if (_hasFocus && !previousFocus) {
      _focusTracker.setFocus(editorId, userId);
    } else if (!_hasFocus && previousFocus) {
      _focusTracker.clearFocus(editorId);
    }
  }

  void onTextChanged(String text, dynamic editorNotifier) {
    if (!_isUpdatingFromState && _hasFocus) {
      _focusTracker.userStartedTyping(userId, editorId);
      
      editorNotifier.updateLocalContent(
        text,
        cursorPosition: _textController.selection.baseOffset,
        userId: userId,
      );
    }
  }

  void onStateChanged(EditorState? previous, EditorState next) {
    if (next.localContent != _textController.text && !_isUpdatingFromState) {
      _isUpdatingFromState = true;
      
      final cursorPosition = _textController.selection.baseOffset;
      _textController.text = next.localContent;
      
      if (cursorPosition >= 0 && cursorPosition <= next.localContent.length) {
        _textController.selection = TextSelection.collapsed(offset: cursorPosition);
      }
      
      // microtask for better performance
      scheduleMicrotask(() {
        _isUpdatingFromState = false;
      });
    }
  }

  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusTracker.clearFocus(editorId);
    _textController.dispose();
    _focusNode.dispose();
  }
}