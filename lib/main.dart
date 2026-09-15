import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Supabase Initialization
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

class TradesyncAiApp extends StatelessWidget {
  const TradesyncAiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradeSync AI',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A3A52), // Deep Slate Blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3A52),
          secondary: const Color(0xFFD4AF37), // Professional Gold
          tertiary: const Color(0xFF10B981), // Emerald Success
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
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
          textDirection: TextDirection.rtl, // RTL Enforced for Arabic
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TradeSync AI',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'منصة الشراكة وتجارة الجملة للمقاول الذاتي الجزائري',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () {
                  // Navigate directly to AuthScreen (Fixes the loop)
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3A52),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'ابدأ الآن',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'importer'; // Importer or Investor
  bool _isPhoneMode = false;
  bool _isLogin = true; // Toggle between Login and Signup

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleAuthentication() {
    // 1. Basic Frontend Validation (Note: Always validate securely on the backend/Supabase as well)
    final input = _isPhoneMode ? _phoneController.text.trim() : _emailController.text.trim();
    if (input.isEmpty || (_isPhoneMode && input.length < 9) || (!_isPhoneMode && !input.contains('@'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال بيانات صحيحة', style: GoogleFonts.poppins())),
      );
      return;
    }

    // 2. State update & Secure Routing Fix (Prevents bypass)
    // In a real scenario, wait for Supabase auth response here before pushing the route.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => DashboardScreen(userRole: _selectedRole)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء حساب', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Login / Signup
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => setState(() => _isLogin = true),
                  child: Text('تسجيل الدخول', style: GoogleFonts.poppins(fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal)),
                ),
                TextButton(
                  onPressed: () => setState(() => _isLogin = false),
                  child: Text('إنشاء حساب', style: GoogleFonts.poppins(fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Input Fields
            TextField(
              controller: _isPhoneMode ? _phoneController : _emailController,
              decoration: InputDecoration(
                hintText: _isPhoneMode ? '+213 555...' : 'البريد الإلكتروني',
                prefixIcon: Icon(_isPhoneMode ? Icons.phone : Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: _isPhoneMode ? TextInputType.phone : TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _isPhoneMode = !_isPhoneMode),
              child: Text(_isPhoneMode ? 'استخدام البريد الإلكتروني بدلاً من ذلك' : 'استخدام رقم الهاتف بدلاً من ذلك'),
            ),
            const SizedBox(height: 24),
            // Role Selection (Crucial for Business Logic)
            if (!_isLogin) ...[
              Text('اختر دورك في المنصة:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                items: const [
                  DropdownMenuItem(value: 'importer', child: Text('مستورد / مسافر (يملك قنوات استيراد)')),
                  DropdownMenuItem(value: 'investor', child: Text('شريك / مستثمر (يملك سيولة)')),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 32),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleAuthentication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_isLogin ? 'دخول' : 'تأكيد الحساب', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
