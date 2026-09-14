import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'themes/app_theme.dart';
import 'providers/app_providers.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(
    const ProviderScope(
      child: TradesyncAiApp(),
    ),
  );
}

class TradesyncAiApp extends ConsumerWidget {
  const TradesyncAiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'TradeSync AI',
      theme: AppTheme.getTheme(context),
      locale: const Locale('ar', 'DZ'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'DZ'),
        Locale('en', 'US'),
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: _getTextDirection(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: switch (authState.status) {
        AuthStatus.unknown || AuthStatus.loading => const SplashScreen(),
        AuthStatus.authenticated => const DashboardScreen(),
        AuthStatus.unauthenticated || AuthStatus.error => const AuthScreen(),
      },
    );
  }

  TextDirection _getTextDirection(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'ar') {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }
}
