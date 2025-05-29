import 'package:co_edit/config/theme.dart';
import 'package:co_edit/firebase_options.dart';
import 'package:co_edit/services/firebase_service.dart';
import 'package:co_edit/views/screens/editor_screen.dart';
import 'package:co_edit/views/screens/onboarding.dart';
import 'package:co_edit/views/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeColorProvider = StateProvider(
  (ref) => const Color.fromARGB(255, 139, 71, 7),
);
final themeModeProvider = StateProvider((ref) => ThemeMode.system);
final hasSeenOnboardingProvider = StateProvider<bool>((ref) => false);
final isAppInitializedProvider = StateProvider<bool>((ref) => false);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
  
  await FirebaseDocumentService().initialize();
  
  runApp(const ProviderScope(child: MyApp()));
}

class AuthWrapperWithSplash extends ConsumerStatefulWidget {
  const AuthWrapperWithSplash({super.key});

  @override
  ConsumerState<AuthWrapperWithSplash> createState() => _AuthWrapperWithSplashState();
}

class _AuthWrapperWithSplashState extends ConsumerState<AuthWrapperWithSplash> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _hideSplashAfterDelay();
  }

  void _hideSplashAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (!hasSeenOnboarding) {
            return const Onboarding();
          }
          return const EditorScreen();
        } else {
          return const SplashScreen();
        }
      },
    );
  }
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeColor = ref.watch(themeColorProvider);

    final lightTheme = AppThemes.lightTheme.copyWith(
      primaryColor: themeColor,
      colorScheme: AppThemes.lightTheme.colorScheme.copyWith(
        primary: themeColor,
      ),
      appBarTheme: AppThemes.lightTheme.appBarTheme.copyWith(
        backgroundColor: themeColor,
      ),
    );

    final darkTheme = AppThemes.darkTheme.copyWith(
      primaryColor: themeColor,
      colorScheme: AppThemes.darkTheme.colorScheme.copyWith(
        primary: themeColor,
      ),
      appBarTheme: AppThemes.darkTheme.appBarTheme.copyWith(
        backgroundColor: themeColor,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CoEdit',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapperWithSplash(),
        '/onboarding': (context) => const Onboarding(),
        '/home': (context) => const EditorScreen(),
      },
    );
  }
}

