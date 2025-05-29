## CoEdit - Collaborative Text Editor
A real-time collaborative text editor built with Flutter, Riverpod, and Firebase Cloud Firestore. Multiple users can edit the same document simultaneously with live synchronization.


## 🚀 Features
🔄 Real-time synchronization across multiple simulated users
📱 Responsive design - side-by-side on wide screens, stacked on narrow screens
🎯 Focus tracking - only shows "typing" indicator for the active editor
🔀 Intelligent diff-merge logic with conflict resolution
🔐 Anonymous authentication with automatic retry
📡 Connection status monitoring and error recovery
⚡ Debounced saving to prevent excessive Firebase writes

## Setup Instructions
1. Firebase Configuration (manual)

Create a new Firebase project at Firebase Console
Enable Cloud Firestore and Authentication
Enable Anonymous Authentication in the Authentication settings
Configure Firestore security rules:

javascriptrules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write documents
    match /documents/{documentId} {
      allow read, write: if request.auth != null;
    }
  }
}

Download google-services.json (Android) and GoogleService-Info.plist (iOS)
Place the configuration files in the appropriate platform directories
 
## Firebase Auto-Setup (FlutterFire)

Create Firebase Project
Enable Cloud Firestore and Anonymous Auth.

Install & Login Firebase CLI:
-bash:
    npm install -g firebase-tools
    firebase login


Run FlutterFire Configure:
-bash
    flutterfire configure \
    --project YOUR_PROJECT_ID \
    --platforms android,ios \
    --android-package-name com.example.co_edit \
    --ios-bundle-id    com.example.coEdit

This generates google-services.json, GoogleService-Info.plist, and lib/firebase_options.dart.

Set Firestore Rules
        rules_version = '2';
        service cloud.firestore {
        match /databases/{database}/documents {
            match /documents/{id} {
            allow read, write: if request.auth != null;
            }
        }
    }
Initialize in main.dart:
-dart
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    );


2. Dependencies
Add these dependencies to your pubspec.yaml:
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1
  firebase_core: ^3.13.1
  cloud_firestore: ^5.6.8
  flutter_launcher_icons: ^0.14.3
  flutter_native_splash: ^2.4.4
  firebase_auth: ^5.5.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

3. Run the Application:
-bash(terminal)
    flutter pub get
    flutter run



## Architecture Overview
Riverpod Providers Structure
1. StreamProvider.family
dartfinal documentStreamProvider = StreamProvider.family<Document, String>((ref, documentId) {
  final firebaseService = ref.watch(firebaseDocumentServiceProvider);
  ref.keepAlive(); // Maintains connection even if widget is temporarily removed
  return firebaseService.streamDocument(documentId);
});

Purpose: Streams real-time document updates from Firestore
Family Parameter: Document ID to support multiple documents
ref.keepAlive(): Ensures the stream stays active during navigation

2. StateNotifierProvider.family
dartfinal editorStateProvider = StateNotifierProvider.family<EditorStateNotifier, EditorState, String>(
  (ref, documentId) {
    return EditorStateNotifier(documentId: documentId, firebaseService: firebaseService);
  },
);

Purpose: Manages local editor state and handles user input
Responsibilities:

Local content management
Cursor position tracking
Debounced saving to Firebase
Merging remote changes with local content



# Provider Interaction Flow

User Types → EditorStateNotifier.updateLocalContent()
Local State Updated → Debounced timer starts
Timer Expires → Content saved to Firebase via FirebaseDocumentService
Remote Change Detected → StreamProvider receives update
Merge Logic Triggered → TextMerger.merge() combines changes
UI Updated → Both editors reflect the merged content

Diff-Merge Strategy
Core Approach: Last-Write-Wins with Intelligent Merging
The TextMerger class implements a sophisticated merge strategy:
1. Simple Cases

Identical content: No merge needed
Empty local: Accept remote content
Empty remote: Keep local content

2. Time-Based Resolution

Compare localLastEdit vs remoteLastEdit timestamps
Newer changes win, but conflicts are detected and flagged

3. Intelligent Merging
When remote is newer, attempt smart merge:

Check if one string contains the other (likely additions)
Find common prefix/suffix to identify changed sections
Combine non-conflicting changes when possible
Fall back to last-write-wins for true conflicts

4. Conflict Detection
dartTextMergeResult result = TextMerger.merge(
  localContent: "Hello World",
  remoteContent: "Hello Universe", 
  localLastEdit: DateTime.now(),
  remoteLastEdit: DateTime.now().subtract(Duration(minutes: 1)),
);
// result.hasConflict = true (local is newer but different)
5. Similarity Calculation
Uses Levenshtein distance algorithm to measure content similarity and make smarter merge decisions.