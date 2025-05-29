import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoEditAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CoEditAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: const Color(0xFF8B4513),
      foregroundColor: Colors.white,
      title: const Text(
        'Collaborative Editor',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevation: 0,
    );
  }
}