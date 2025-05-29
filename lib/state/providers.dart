import 'package:co_edit/models/document.dart';
import 'package:co_edit/services/firebase_service.dart';
import 'package:co_edit/state/editor_notifier.dart';
import 'package:co_edit/state/editor_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseDocumentServiceProvider = Provider<FirebaseDocumentService>((ref) {
  return FirebaseDocumentService();
});

final firebaseServiceProvider = FutureProvider<FirebaseDocumentService>((ref) async {
  final service = FirebaseDocumentService();
  await service.initialize();
  return service;
});

final documentStreamProvider = StreamProvider.family<Document, String>((ref, documentId) {
  final firebaseService = ref.watch(firebaseDocumentServiceProvider);
  ref.keepAlive();
  return firebaseService.streamDocument(documentId);
});

final documentExistsProvider = FutureProvider.family<bool, String>((ref, documentId) {
  final firebaseService = ref.watch(firebaseDocumentServiceProvider);
  return firebaseService.documentExists(documentId);
});

final editorStateProvider = StateNotifierProvider.family<EditorStateNotifier, EditorState, String>(
  (ref, documentId) {
    final firebaseService = ref.watch(firebaseDocumentServiceProvider);
    
    return EditorStateNotifier(
      documentId: documentId,
      firebaseService: firebaseService,
    );
  },
);

final currentDocumentIdProvider = StateProvider<String>((ref) {
  return 'default_document';
});

final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

final collabDocumentIdsProvider = StateProvider<List<String>>((ref) {
  return ['doc1', 'doc2'];
});

final currentCollabDocumentIdProvider = Provider<String>((ref) {
  final tabIndex = ref.watch(selectedTabIndexProvider);
  final documentIds = ref.watch(collabDocumentIdsProvider);
  return documentIds[tabIndex];
});

final globalConnectionStatusProvider = Provider<ConnectionStatus>((ref) {
  final documentIds = ref.watch(collabDocumentIdsProvider);
  
  ConnectionStatus overallStatus = ConnectionStatus.connected;
  
  for (final docId in documentIds) {
    final editorState = ref.watch(editorStateProvider(docId));
    
    if (editorState.connectionStatus == ConnectionStatus.error) {
      return ConnectionStatus.error;
    } else if (editorState.connectionStatus == ConnectionStatus.syncing) {
      overallStatus = ConnectionStatus.syncing;
    } else if (editorState.connectionStatus == ConnectionStatus.connecting) {
      overallStatus = ConnectionStatus.connecting;
    }
  }
  
  return overallStatus;
});

final hasUnsavedChangesProvider = Provider<bool>((ref) {
  final documentIds = ref.watch(collabDocumentIdsProvider);
  
  for (final docId in documentIds) {
    final editorState = ref.watch(editorStateProvider(docId));
    if (editorState.hasUnsavedChanges) return true;
  }
  
  return false;
});

class DocumentOperations {
  final Ref _ref;
  
  DocumentOperations(this._ref);
  
  Future<void> createDocument(String documentId, [String? initialContent]) async {
    final service = _ref.read(firebaseDocumentServiceProvider);
    await service.createDocument(documentId, initialContent);
  }
  
  Future<void> saveAll() async {
    final documentIds = _ref.read(collabDocumentIdsProvider);
    
    for (final docId in documentIds) {
      final editor = _ref.read(editorStateProvider(docId).notifier);
      await editor.forceSave();
    }
  }
  
  void retryAllConnections() {
    final documentIds = _ref.read(collabDocumentIdsProvider);
    
    for (final docId in documentIds) {
      final editor = _ref.read(editorStateProvider(docId).notifier);
      editor.retryConnection();
    }
  }
}

final documentOperationsProvider = Provider<DocumentOperations>((ref) {
  return DocumentOperations(ref);
});