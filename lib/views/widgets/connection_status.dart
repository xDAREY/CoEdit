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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isConnected
          ? const Color(0xFFE8F5E8)
          : const Color(0xFFFFE8E8),
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
                  ? Colors.green[800]
                  : Colors.red[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}