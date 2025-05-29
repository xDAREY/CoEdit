import 'dart:async';
import 'package:flutter/material.dart';

class GlobalFocusTracker {
  static final GlobalFocusTracker _instance = GlobalFocusTracker._internal();
  factory GlobalFocusTracker() => _instance;
  GlobalFocusTracker._internal();
  
  String? _currentlyFocusedEditor;
  String? _activeTypingEditor; 
  Timer? _typingTimer;
  
  final ValueNotifier<String?> activeTypingEditorNotifier = ValueNotifier<String?>(null);
  
  void setFocus(String editorId, String userId) {
    if (_currentlyFocusedEditor != null && _currentlyFocusedEditor != editorId) {
      _stopTyping();
    }
    _currentlyFocusedEditor = editorId;
  }

  void clearFocus(String editorId) {
    if (_currentlyFocusedEditor == editorId) {
      _stopTyping();
      _currentlyFocusedEditor = null;
    }
  }

  void userStartedTyping(String userId, String editorId) {
    if (_currentlyFocusedEditor == editorId) {
      _activeTypingEditor = editorId;
      activeTypingEditorNotifier.value = editorId;
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(milliseconds: 1500), _stopTyping);
    }
  }

  void _stopTyping() {
    if (_activeTypingEditor != null) {
      _activeTypingEditor = null;
      activeTypingEditorNotifier.value = null;
    }
    _typingTimer?.cancel();
  }
  
  bool shouldShowTypingIndicator(String editorId) {
    return _activeTypingEditor == editorId;
  }
  
  bool get isSomeoneTyping => _activeTypingEditor != null;
  
  String? get currentlyFocusedEditor => _currentlyFocusedEditor;
  
  void dispose() {
    _typingTimer?.cancel();
    activeTypingEditorNotifier.dispose();
  }
}
