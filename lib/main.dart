import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'themes/app_theme.dart';
import 'models/app_models.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize Supabase when credentials are available
  // await Supabase.initialize(
  //   url: 'YOUR_SUPABASE_URL',
  //   anonKey: 'YOUR_SUPABASE_ANON_KEY',
  // );
  
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
    final isAuthenticated = ref.watch(userAuthProvider) != null;
    final userRole = ref.watch(userRoleProvider);

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
      home: isAuthenticated && userRole != null
          ? const DashboardScreen()
          : const SplashScreen(),
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
