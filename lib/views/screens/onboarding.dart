import 'package:co_edit/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Onboarding extends ConsumerWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40)),
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/icons/note_icon.png',  
                height: 80,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Collaborative Edit",
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 5),
            Text(
              "Real-time collaboration made simple",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            _decisionCard(
              context: context,
              icon: Icons.edit,
              title: "Real-time Editing",
              subtitle: "See changes as they happen",
            ),
            const SizedBox(height: 30),
            _decisionCard(
              context: context,
              icon: Icons.group_add_outlined,
              title: "Multi-user Support",
              subtitle: "Work with teammates",
            ),
            const SizedBox(height: 30),
            _decisionCard(
              context: context,
              icon: Icons.sync,
              title: "Instant Sync",
              subtitle: "Changes sync automatically",
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(hasSeenOnboardingProvider.notifier).state = true;
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                  ),
                  child: const Text(
                    "Start Collaborating",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _decisionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    final darkerPrimary = Color.fromRGBO(
      (primaryColor.r * 0.70).round(),
      (primaryColor.g * 0.70).round(),
      (primaryColor.b * 0.70).round(),
      1.0,
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, darkerPrimary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
