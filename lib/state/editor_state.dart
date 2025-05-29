import 'package:co_edit/models/document.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  syncing,
  error,
}

class EditorState {
  final String documentId;
  final String localContent;
  final int cursorPosition;
  final ConnectionStatus connectionStatus;
  final Document? remoteDocument;
  final bool hasUnsavedChanges;
  final String? errorMessage;
  final DateTime lastLocalEdit;

  const EditorState({
    required this.documentId,
    required this.localContent,
    this.cursorPosition = 0,
    this.connectionStatus = ConnectionStatus.disconnected,
    this.remoteDocument,
    this.hasUnsavedChanges = false,
    this.errorMessage,
    required this.lastLocalEdit,
  });

  factory EditorState.initial(String documentId) {
    return EditorState(
      documentId: documentId,
      localContent: '',
      lastLocalEdit: DateTime.now(),
    );
  }

  EditorState copyWith({
    String? documentId,
    String? localContent,
    int? cursorPosition,
    ConnectionStatus? connectionStatus,
    Document? remoteDocument,
    bool? hasUnsavedChanges,
    String? errorMessage,
    DateTime? lastLocalEdit,
  }) {
    return EditorState(
      documentId: documentId ?? this.documentId,
      localContent: localContent ?? this.localContent,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      remoteDocument: remoteDocument ?? this.remoteDocument,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      errorMessage: errorMessage ?? this.errorMessage,
      lastLocalEdit: lastLocalEdit ?? this.lastLocalEdit,
    );
  }

  bool get hasConflict {
    if (remoteDocument == null) return false;
    return localContent != remoteDocument!.content && hasUnsavedChanges;
  }

  String get statusMessage {
    switch (connectionStatus) {
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.connected:
        return hasUnsavedChanges ? 'Unsaved changes' : 'Connected';
      case ConnectionStatus.syncing:
        return 'Syncing...';
      case ConnectionStatus.error:
        return errorMessage ?? 'Connection error';
    }
  }

  @override
  String toString() {
    return 'EditorState(documentId: $documentId, '
           'content: ${localContent.length} chars, '
           'status: $connectionStatus, '
           'hasUnsavedChanges: $hasUnsavedChanges)';
  }
}