import 'package:co_edit/views/widgets/connection_status.dart';
import 'package:co_edit/views/widgets/editor_appbar.dart';
import 'package:co_edit/views/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CoEditAppBar(),
      body: Column(
        children: [
          const ConnectionStatusBar(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 800;
                return ResponsiveEditorLayout(isWideScreen: isWideScreen);
              },
            ),
          ),
        ],
      ),
    );
  }
}