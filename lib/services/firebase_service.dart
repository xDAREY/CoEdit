import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_edit/models/document.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDocumentService {
  static const String _collectionName = 'documents';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _initialized = false;
  
  String get currentUserId => _auth.currentUser?.uid ?? 'anonymous';
  
  bool get isAuthenticated => _auth.currentUser != null;

  CollectionReference get _documentsRef => 
      _firestore.collection(_collectionName);

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await _ensureAnonymousAuth();
      await _testFirestoreConnection();
      _initialized = true;
      
    } catch (e) {
      _initialized = false;
      throw Exception('Failed to initialize service');
    }
  }

  Future<String> _ensureAnonymousAuth() async {
    try {
      User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        final userCredential = await _auth.signInAnonymously();
        currentUser = userCredential.user;
        await Future.delayed(Duration(milliseconds: 500));
      }
      
      return currentUser?.uid ?? 'anonymous';
      
    } catch (e) {
      throw Exception('Authentication failed');
    }
  }

  Future<void> _testFirestoreConnection() async {
    try {
      await _firestore.collection('test').limit(1).get();
      
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        return;
      }
      
      throw Exception('Connection failed');
    }
  }

  Future<String> signInAnonymously() async {
    try {
      await _auth.signOut();
      await Future.delayed(Duration(milliseconds: 500));
      
      final userCredential = await _auth.signInAnonymously();
      final uid = userCredential.user?.uid ?? 'anonymous';
      
      return uid;
    } catch (e) {
      throw Exception('Sign-in failed');
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
    
    if (!isAuthenticated) {
      await _ensureAnonymousAuth();
    }
  }

  Stream<Document> streamDocument(String documentId) {
    return _documentsRef
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return Document.empty(documentId);
      }
      return Document.fromFirestore(snapshot);
    }).handleError((error) {
      if (error.toString().contains('permission-denied')) {
        // Re-authentication needed
      }
      
      throw error;
    });
  }

  Future<Document> getDocument(String documentId) async {
    await _ensureInitialized();
    
    try {
      final snapshot = await _documentsRef.doc(documentId).get();
      
      if (!snapshot.exists) {
        return Document.empty(documentId);
      }
      
      return Document.fromFirestore(snapshot);
      
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        await signInAnonymously();
        
        final snapshot = await _documentsRef.doc(documentId).get();
        if (!snapshot.exists) {
          return Document.empty(documentId);
        }
        return Document.fromFirestore(snapshot);
      }
      
      throw Exception('Unable to load document');
    }
  }

  Future<void> applyOperation(String documentId, DocumentOperation operation) async {
    await _ensureInitialized();
    
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _documentsRef.doc(documentId);
        final snapshot = await transaction.get(docRef);
        
        Document currentDoc;
        if (!snapshot.exists) {
          currentDoc = Document.empty(documentId);
        } else {
          currentDoc = Document.fromFirestore(snapshot);
        }
        
        final updatedDoc = currentDoc.addOperation(operation);
        transaction.set(docRef, updatedDoc.toFirestore());
      });
      
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        await signInAnonymously();
        throw Exception('Please try again');
      }
      
      throw Exception('Unable to save changes');
    }
  }

  Future<void> insertText(String documentId, int position, String text) async {
    final operation = DocumentOperation.insert(
      position: position,
      text: text,
      userId: currentUserId,
    );
    
    await applyOperation(documentId, operation);
  }

  Future<void> deleteText(String documentId, int position, int length) async {
    final operation = DocumentOperation.delete(
      position: position,
      length: length,
      userId: currentUserId,
    );
    
    await applyOperation(documentId, operation);
  }

  Future<void> replaceContent(String documentId, String newContent) async {
    await _ensureInitialized();
    
    try {
      final operation = DocumentOperation(
        type: 'replace',
        position: 0,
        text: newContent,
        timestamp: DateTime.now(),
        userId: currentUserId,
      );
      
      await _firestore.runTransaction((transaction) async {
        final docRef = _documentsRef.doc(documentId);
        final snapshot = await transaction.get(docRef);
        
        Document currentDoc;
        if (!snapshot.exists) {
          currentDoc = Document.empty(documentId);
        } else {
          currentDoc = Document.fromFirestore(snapshot);
        }
        
        final updatedDoc = currentDoc.copyWith(
          content: newContent,
          version: currentDoc.version + 1,
          lastModified: DateTime.now(),
          operations: [...currentDoc.operations, operation],
        );
        
        transaction.set(docRef, updatedDoc.toFirestore());
      });
      
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        await signInAnonymously();
        throw Exception('Please try again');
      }
      
      throw Exception('Unable to update content');
    }
  }

  Future<Document> createDocument(String documentId, [String? initialContent]) async {
    await _ensureInitialized();
    
    try {
      final content = initialContent ?? '';
      final document = Document(
        id: documentId,
        content: content,
        version: 1,
        lastModified: DateTime.now(),
        operations: content.isNotEmpty ? [
          DocumentOperation.insert(
            position: 0,
            text: content,
            userId: currentUserId,
          )
        ] : [],
      );

      await _documentsRef
          .doc(documentId)
          .set(document.toFirestore());

      return document;
      
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        await signInAnonymously();
        throw Exception('Please try again');
      }
      
      throw Exception('Unable to create document');
    }
  }

  Future<bool> documentExists(String documentId) async {
    await _ensureInitialized();
    
    try {
      final snapshot = await _documentsRef.doc(documentId).get();
      return snapshot.exists;
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        await signInAnonymously();
        final snapshot = await _documentsRef.doc(documentId).get();
        return snapshot.exists;
      }
      
      return false;
    }
  }

  Future<List<DocumentOperation>> getOperationsAfterVersion(
    String documentId, 
    int afterVersion
  ) async {
    final document = await getDocument(documentId);
    return document.getOperationsAfterVersion(afterVersion);
  }

  Future<void> deleteDocument(String documentId) async {
    await _ensureInitialized();
    
    try {
      await _documentsRef.doc(documentId).delete();
    } catch (e) {
      throw Exception('Unable to delete document');
    }
  }

  Map<String, dynamic> getAuthStatus() {
    final user = _auth.currentUser;
    return {
      'isAuthenticated': user != null,
      'userId': user?.uid,
      'isAnonymous': user?.isAnonymous ?? false,
      'initialized': _initialized,
    };
  }

  Future<void> reset() async {
    _initialized = false;
    await _auth.signOut();
    await Future.delayed(Duration(milliseconds: 500));
    await initialize();
  }
}