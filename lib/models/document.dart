import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentOperation {
  final String type;
  final int position;
  final String? text;
  final DateTime timestamp;
  final String userId;

  const DocumentOperation({
    required this.type,
    required this.position,
    this.text,
    required this.timestamp,
    required this.userId,
  });

  factory DocumentOperation.fromMap(Map<String, dynamic> map) {
    return DocumentOperation(
      type: map['type'] ?? '',
      position: map['position'] ?? 0,
      text: map['text'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      userId: map['userId'] ?? 'anonymous',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'position': position,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
    };
  }

  factory DocumentOperation.insert({
    required int position,
    required String text,
    required String userId,
  }) {
    return DocumentOperation(
      type: 'insert',
      position: position,
      text: text,
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  factory DocumentOperation.delete({
    required int position,
    required int length,
    required String userId,
  }) {
    return DocumentOperation(
      type: 'delete',
      position: position,
      text: length.toString(), 
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  @override
  String toString() {
    return 'DocumentOperation(type: $type, position: $position, text: $text, userId: $userId)';
  }
}

class Document {
  final String id;
  final String content;
  final int version;
  final DateTime lastModified;
  final List<DocumentOperation> operations;

  const Document({
    required this.id,
    required this.content,
    required this.version,
    required this.lastModified,
    required this.operations,
  });

  factory Document.empty(String id) {
    return Document(
      id: id,
      content: '',
      version: 0,
      lastModified: DateTime.now(),
      operations: [],
    );
  }

  factory Document.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final operationsData = data['operations'] as List<dynamic>? ?? [];
    final operations = operationsData
        .map((op) => DocumentOperation.fromMap(op as Map<String, dynamic>))
        .toList();
    
    return Document(
      id: doc.id,
      content: data['content'] ?? '',
      version: data['version'] ?? 0,
      lastModified: (data['lastModified'] as Timestamp).toDate(),
      operations: operations,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'version': version,
      'lastModified': Timestamp.fromDate(lastModified),
      'operations': operations.map((op) => op.toMap()).toList(),
    };
  }

  Document copyWith({
    String? id,
    String? content,
    int? version,
    DateTime? lastModified,
    List<DocumentOperation>? operations,
  }) {
    return Document(
      id: id ?? this.id,
      content: content ?? this.content,
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
      operations: operations ?? this.operations,
    );
  }

  Document addOperation(DocumentOperation operation) {
    final newOperations = [...operations, operation];
    
    String newContent = content;
    
    switch (operation.type) {
      case 'insert':
        if (operation.text != null && operation.position <= newContent.length) {
          newContent = newContent.substring(0, operation.position) +
              operation.text! +
              newContent.substring(operation.position);
        }
        break;
      case 'delete':
        if (operation.text != null) {
          final length = int.tryParse(operation.text!) ?? 0;
          if (operation.position < newContent.length) {
            final endPos = (operation.position + length).clamp(0, newContent.length);
            newContent = newContent.substring(0, operation.position) +
                newContent.substring(endPos);
          }
        }
        break;
    }

    return copyWith(
      content: newContent,
      version: version + 1,
      lastModified: DateTime.now(),
      operations: newOperations,
    );
  }

  // Get operations after a specific version (for syncing)
  List<DocumentOperation> getOperationsAfterVersion(int afterVersion) {
    // Since we don't store version with each operation in this simple model,
    // we'll return recent operations based on timestamp
    // In a more complex system, you'd store version
    // with each operation (something like Google Docs(lol)).
    // lol = the approach would be too brazyyy for me to implement rn.
    final cutoffTime = DateTime.now().subtract(const Duration(minutes: 5));
    return operations.where((op) => op.timestamp.isAfter(cutoffTime)).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Document &&
        other.id == id &&
        other.content == content &&
        other.version == version &&
        other.lastModified == lastModified;
  }

  @override
  int get hashCode {
    return Object.hash(id, content, version, lastModified);
  }

  @override
  String toString() {
    return 'Document(id: $id, content: ${content.length} chars, version: $version, operations: ${operations.length})';
  }
}