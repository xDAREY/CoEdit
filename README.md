# CoEdit — Collaborative Text Editor

A real-time collaborative text editor built with **Flutter**, **Riverpod**, and **Firebase Cloud Firestore**. Multiple users can edit the same document simultaneously with live synchronization.

---

## 🚀 Features

* 🔄 **Real-time sync**: Live updates across multiple simulated users
* 📱 **Responsive UI**: Side-by-side editors on wide screens, stacked on narrow
* 🎯 **Focus tracking**: “Typing…” indicator only on the active editor
* 🔀 **Diff-merge logic**: Intelligent conflict resolution
* 🔐 **Anonymous auth**: Zero-UI sign-in with retry
* 📡 **Connection monitoring**: Status & automatic recovery
* ⚡ **Debounced saves**: Prevents excessive Firestore writes

---

## 🛠️ Setup

### 1. Firebase Auto-Setup (FlutterFire)

1. **Create & configure** a Firebase project

   * Enable **Cloud Firestore**
   * Enable **Anonymous Authentication**

2. **Install & authenticate** the Firebase CLI

   ```bash
   npm install -g firebase-tools
   firebase login
   ```

3. **Generate config files**

   ```bash
   flutterfire configure \
     --project YOUR_PROJECT_ID \
     --platforms android,ios \
     --android-package-name com.example.co_edit \
     --ios-bundle-id    com.example.coEdit
   ```

   This creates:

   * `android/app/google-services.json`
   * `ios/Runner/GoogleService-Info.plist`
   * `lib/firebase_options.dart`

4. **Secure Firestore rules**
   In Firebase Console → Firestore → **Rules**:

   ```js
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /documents/{documentId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

5. **Initialize in `main.dart`**

   ```dart
   import 'firebase_options.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(const ProviderScope(child: MyApp()));
   }
   ```

---

### 2. Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1
  firebase_core: ^3.13.1
  cloud_firestore: ^5.6.8
  firebase_auth: ^5.5.4
  flutter_launcher_icons: ^0.14.3
  flutter_native_splash: ^2.4.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

### 3. Run the App

```bash
flutter pub get
flutter run
```

---

## 🏛️ Architecture Overview

### Riverpod Providers

1. **`StreamProvider.family<Document, String>`**
   Streams real-time updates from Firestore:

   ```dart
   final documentStreamProvider = StreamProvider.family<Document, String>(
     (ref, documentId) {
       ref.keepAlive();
       return ref.watch(firebaseServiceProvider)
                 .streamDocument(documentId);
     },
   );
   ```

2. **`StateNotifierProvider.family<EditorStateNotifier, EditorState, String>`**
   Manages local edits, merges, and saving:

   ```dart
   final editorStateProvider = StateNotifierProvider.family<
     EditorStateNotifier, EditorState, String>(
     (ref, documentId) {
       return EditorStateNotifier(
         documentId: documentId,
         firebaseService: ref.watch(firebaseServiceProvider),
       );
     },
   );
   ```

#### Provider Interaction Flow

1. **User types** → `EditorStateNotifier.updateLocalContent()`
2. **Local state updates** → debounced save timer starts
3. **Timer expires** → content saved to Firestore
4. **Remote change** → `StreamProvider` emits update
5. **Merge logic** → `TextMerger.merge()` combines edits
6. **UI refreshes** → both editors show merged content

---

## 🔍 Diff-Merge Strategy

* **Core**: Last-Write-Wins with intelligent merging
* **Simple cases**:

  * Empty vs. non-empty → take the non-empty
  * Identical → no action
* **Timestamp resolution**: newer edit wins
* **Smart merge**: common prefix/suffix detection
* **Conflict detection**: flags when local & remote both changed

```dart
final result = TextMerger.merge(
  localContent:  "Hello World",
  remoteContent: "Hello Universe",
  localLastEdit: DateTime.now(),
  remoteLastEdit: DateTime.now().subtract(Duration(minutes: 1)),
);
// result.hasConflict == true
```

---

## 🎁 Bonus Features

* 🔍 **Advanced focus tracking**: per-user typing indicators with global tracker
* 🛡️ **Professional error recovery**: automatic retry and graceful fallbacks
* 📏 **Responsive design**: adaptive layout for all screen sizes
* 🤖 **Sophisticated merge algorithms**: similarity detection & conflict resolution
* 🔄 **Auth retry logic**: robust anonymous sign-in with error handling
* 📶 **Connection status UI**: visual indicators for connectivity & syncing
* 🎨 **Theming & UI**: customizable themes and polished interface

---
