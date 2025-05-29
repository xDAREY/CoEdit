// import 'package:co_edit/services/firebase_service.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ConnectionTestWidget extends StatefulWidget {
//   final FirebaseDocumentService firebaseService;
  
//   const ConnectionTestWidget({
//     super.key,
//     required this.firebaseService,
//   });

//   @override
//   State<ConnectionTestWidget> createState() => _ConnectionTestWidgetState();
// }

// class _ConnectionTestWidgetState extends State<ConnectionTestWidget> {
//   String _status = 'Not tested';
//   bool _isLoading = false;
  
//   @override
//   void initState() {
//     super.initState();
//     _runConnectionTest();
//   }
  
//   Future<void> _runConnectionTest() async {
//     setState(() {
//       _isLoading = true;
//       _status = 'Testing connection...';
//     });
    
//     try {
//       // Test 1: Check authentication
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         setState(() {
//           _status = 'No authenticated user';
//           _isLoading = false;
//         });
//         return;
//       }
      
//       setState(() {
//         _status = ' User authenticated: ${user.uid}\nTesting Firestore...';
//       });
      
//       // Test 2: Test basic Firestore write
//       await FirebaseFirestore.instance
//           .collection('documents')
//           .doc('connection_test')
//           .set({
//         'test': 'Connection test',
//         'timestamp': FieldValue.serverTimestamp(),
//         'user': user.uid,
//       });
      
//       setState(() {
//         _status = 'Firestore write successful\nTesting read...';
//       });
      
//       // Test 3: Test basic Firestore read
//       final doc = await FirebaseFirestore.instance
//           .collection('documents')
//           .doc('connection_test')
//           .get();
      
//       if (!doc.exists) {
//         setState(() {
//           _status = 'Document read failed - document does not exist';
//           _isLoading = false;
//         });
//         return;
//       }
      
//       setState(() {
//         _status = ' Firestore read successful\nTesting document service...';
//       });
      
//       // Test 4: Test document service
//       await widget.firebaseService.initialize();
//       final testDoc = await widget.firebaseService.getDocument('test_document');
      
//       setState(() {
//         _status = ''' All tests passed!
//         Auth: ${user.uid}
//         Firestore: Connected
//         Document Service: Initialized
//         Test Document: ${testDoc.content.length} chars''';
//       });
              
//       // Clean up
//       await FirebaseFirestore.instance
//           .collection('documents')
//           .doc('connection_test')
//           .delete();
      
//     } catch (e) {
//       setState(() {
//         _status = ' Connection test failed:\n$e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(16),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   _isLoading 
//                       ? Icons.sync 
//                       : _status.contains('❌') 
//                           ? Icons.error 
//                           : Icons.check_circle,
//                   color: _isLoading 
//                       ? Colors.orange 
//                       : _status.contains('❌') 
//                           ? Colors.red 
//                           : Colors.green,
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   'Firebase Connection Test',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             if (_isLoading)
//               LinearProgressIndicator()
//             else
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   _status,
//                   style: TextStyle(fontFamily: 'montserrat',
//                     fontSize: 14,
//                     color: _status.contains('❌') ? Colors.red : Colors.black87,
//                   ),
//                 ),
//               ),
//             SizedBox(height: 12),
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _isLoading ? null : _runConnectionTest,
//                   icon: Icon(Icons.refresh),
//                   label: Text('Test Again'),
//                 ),
//                 SizedBox(width: 8),
//                 TextButton.icon(
//                   onPressed: () {
//                     FirebaseAuth.instance.signInAnonymously();
//                   },
//                   icon: Icon(Icons.login),
//                   label: Text('Re-authenticate'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }