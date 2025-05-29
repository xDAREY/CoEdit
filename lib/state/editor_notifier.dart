import 'dart:async';

import 'package:co_edit/models/document.dart';
import 'package:co_edit/services/firebase_service.dart';
import 'package:co_edit/state/editor_state.dart';
import 'package:co_edit/utils/text_merger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditorStateNotifier extends StateNotifier<EditorState> {
  final FirebaseDocumentService _firebaseService;
  final String documentId;
  
  StreamSubscription<Document>? _documentSubscription;
  Timer? _debounceTimer;
  final bool _isDisposed = false;

  static const Duration _debounceDuration = Duration(milliseconds: 1500);

  EditorStateNotifier({
    required this.documentId,
    required FirebaseDocumentService firebaseService,
  }) : _firebaseService = firebaseService,
       super(EditorState.initial(documentId)) {
    _initializeEditor();
  }

  void _initializeEditor() async {
    if (_isDisposed) return;

    state = state.copyWith(connectionStatus: ConnectionStatus.connecting);
    
    try {
      await _ensureAuthentication();
      await _firebaseService.initialize();
      await Future.delayed(Duration(milliseconds: 500));
      
      final initialDocument = await _firebaseService.getDocument(documentId);
      
      state = state.copyWith(
        localContent: initialDocument.content,
        remoteDocument: initialDocument,
        connectionStatus: ConnectionStatus.connected,
      );
      
      _documentSubscription = _firebaseService
          .streamDocument(documentId)
          .listen(
            _handleRemoteDocumentChange,
            onError: _handleStreamError,
          );
      
    } catch (e) {
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('CONFIGURATION_NOT_FOUND')) {
        await _retryWithAuth();
      } else {
        state = state.copyWith(
          connectionStatus: ConnectionStatus.error,
          errorMessage: 'Unable to connect to document',
        );
      }
    }
  }

  Future<void> _ensureAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      try {
        final _ = await FirebaseAuth.instance.signInAnonymously();
        await Future.delayed(Duration(milliseconds: 1000));
        
      } catch (authError) {
        throw Exception('Authentication failed');
      }
    }
  }

  Future<void> _retryWithAuth() async {
    try {
      await FirebaseAuth.instance.signOut();
      await Future.delayed(Duration(milliseconds: 500));
      
      await FirebaseAuth.instance.signInAnonymously();
      await Future.delayed(Duration(milliseconds: 1000));
      
      await _firebaseService.initialize();
      
      final initialDocument = await _firebaseService.getDocument(documentId);
      
      state = state.copyWith(
        localContent: initialDocument.content,
        remoteDocument: initialDocument,
        connectionStatus: ConnectionStatus.connected,
        errorMessage: null,
      );
      
      _documentSubscription = _firebaseService
          .streamDocument(documentId)
          .listen(
            _handleRemoteDocumentChange,
            onError: _handleStreamError,
          );
      
    } catch (retryError) {
      state = state.copyWith(
        connectionStatus: ConnectionStatus.error,
        errorMessage: 'Connection failed',
      );
    }
  }

  void _handleRemoteDocumentChange(Document remoteDocument) {
    final previousRemote = state.remoteDocument;
    state = state.copyWith(remoteDocument: remoteDocument);

    if (previousRemote == null && state.localContent.isEmpty) {
      state = state.copyWith(
        localContent: remoteDocument.content,
        connectionStatus: ConnectionStatus.connected,
      );
      return;
    }

    if (!state.hasUnsavedChanges) {
      state = state.copyWith(
        localContent: remoteDocument.content,
        connectionStatus: ConnectionStatus.connected,
      );
      return;
    }

    _mergeRemoteChanges(remoteDocument);
  }

  void _mergeRemoteChanges(Document remoteDocument) {
    try {
      final mergeResult = TextMerger.merge(
        localContent: state.localContent,
        remoteContent: remoteDocument.content,
        localLastEdit: state.lastLocalEdit,
        remoteLastEdit: remoteDocument.lastModified,
      );

      state = state.copyWith(
        localContent: mergeResult.content,
        hasUnsavedChanges: mergeResult.hasConflict,
        connectionStatus: mergeResult.hasConflict 
            ? ConnectionStatus.connected
            : ConnectionStatus.connected,
      );
      
    } catch (e) {
      state = state.copyWith(
        connectionStatus: ConnectionStatus.error,
        errorMessage: 'Unable to merge changes',
      );
    }
  }

  void _handleStreamError(error) {
    if (error.toString().contains('permission-denied')) {
      state = state.copyWith(
        connectionStatus: ConnectionStatus.error,
        errorMessage: 'Reconnecting...',
      );
      
      Timer(Duration(seconds: 2), () {
        _retryWithAuth();
      });
    } else {
      state = state.copyWith(
        connectionStatus: ConnectionStatus.error,
        errorMessage: 'Connection lost',
      );
      
      Timer(Duration(seconds: 5), () {
        retryConnection();
      });
    }
  }

  void updateLocalContent(String newContent, {int? cursorPosition, String? userId}) {
    _debounceTimer?.cancel();
    
    state = state.copyWith(
      localContent: newContent,
      cursorPosition: cursorPosition ?? state.cursorPosition,
      hasUnsavedChanges: true,
      lastLocalEdit: DateTime.now(),
      connectionStatus: state.connectionStatus == ConnectionStatus.error 
          ? ConnectionStatus.error 
          : ConnectionStatus.connected,
    );

    _debounceTimer = Timer(_debounceDuration, () {
      _saveToFirebase();
    });
  }

  Future<void> _saveToFirebase() async {
    if (!state.hasUnsavedChanges) return;

    try {
      state = state.copyWith(connectionStatus: ConnectionStatus.syncing);
      
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      await _firebaseService.replaceContent(documentId, state.localContent);
      
      state = state.copyWith(
        hasUnsavedChanges: false,
        connectionStatus: ConnectionStatus.connected,
        errorMessage: null,
      );
      
    } catch (e) {
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('not authenticated')) {
        await _retryWithAuth();
      } else {
        state = state.copyWith(
          connectionStatus: ConnectionStatus.error,
          errorMessage: 'Unable to save changes',
        );
      }
    }
  }

  Future<void> forceSave() async {
    _debounceTimer?.cancel();
    await _saveToFirebase();
  }

  void insertText(String text, int position) {
    if (position < 0 || position > state.localContent.length) {
      return;
    }
    
    final newContent = state.localContent.substring(0, position) +
                      text +
                      state.localContent.substring(position);
    
    updateLocalContent(newContent, cursorPosition: position + text.length);
  }

  void deleteText(int position, int length) {
    if (position < 0 || position >= state.localContent.length) {
      return;
    }
    
    final endPosition = (position + length).clamp(0, state.localContent.length);
    final newContent = state.localContent.substring(0, position) +
                      state.localContent.substring(endPosition);
    
    updateLocalContent(newContent, cursorPosition: position);
  }

  void updateCursorPosition(int position) {
    if (position >= 0 && position <= state.localContent.length) {
      state = state.copyWith(cursorPosition: position);
    }
  }

  void retryConnection() {
    _documentSubscription?.cancel();
    _debounceTimer?.cancel();
    
    state = state.copyWith(
      connectionStatus: ConnectionStatus.connecting,
      errorMessage: null,
    );
    
    _initializeEditor();
  }

  Map<String, dynamic> getDocumentStats() {
    final document = state.remoteDocument;
    return {
      'localLength': state.localContent.length,
      'remoteLength': document?.content.length ?? 0,
      'version': document?.version ?? 0,
      'operations': document?.operations.length ?? 0,
      'lastModified': document?.lastModified,
      'hasConflict': state.hasUnsavedChanges && document != null,
      'connectionStatus': state.connectionStatus.toString(),
      'hasUnsavedChanges': state.hasUnsavedChanges,
      'userId': FirebaseAuth.instance.currentUser?.uid,
    };
  }

  Future<bool> checkConnection() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return false;
      }
      
      final _ = await _firebaseService.documentExists(documentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _documentSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}