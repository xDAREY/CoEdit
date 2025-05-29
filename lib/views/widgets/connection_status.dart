import 'package:co_edit/state/editor_state.dart';
import 'package:co_edit/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionStatusBar extends ConsumerWidget {
  const ConnectionStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(globalConnectionStatusProvider);
    final isConnected = status == ConnectionStatus.connected;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isConnected
          ? (isDark ? const Color(0xFF1A3D1A) : const Color(0xFFE8F5E8))
          : (isDark ? const Color(0xFF3D1A1A) : const Color(0xFFFFE8E8)),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              fontSize: 14,
              color: isConnected
                  ? (isDark ? Colors.green[300] : Colors.green[800])
                  : (isDark ? Colors.red[300] : Colors.red[800]),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
