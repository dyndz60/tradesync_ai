import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة الاتصال بـ Supabase باستخدام مفتاح الـ anon العام والآمن فقط
  await Supabase.initialize(
    url: 'https://zcpfuxmjcctuhtjipokx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpjcGZ1eG1qY2N0dWh0amlwb2t4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk0NDA1MjcsImV4cCI6MjEwNTAxNjUyN30.qKabIQ0LLgc8Ze5TVV2A-ASoVZUl6-t9G72cDp-Qt1E',
  );

  runApp(const ProviderScope(child: TradesyncAiApp()));
}

final supabase = Supabase.instance.client;

class TradesyncAiApp extends StatelessWidget {
  const TradesyncAiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradeSync AI',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A3A52), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3A52),
          secondary: const Color(0xFFD4AF37), 
          tertiary: const Color(0xFF10B981), 
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
          textDirection: TextDirection.rtl, 
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
              Text('TradeSync AI', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              const SizedBox(height: 16),
              Text('منصة الشراكة وتجارة الجملة للمقاول الذاتي الجزائري', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]), textAlign: TextAlign.center),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AuthScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3A52), padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
                child: Text('ابدأ الآن', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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
  String _selectedRole = 'importer'; 
  bool _isLoading = false;

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال بريد إلكتروني صحيح')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signUp(
        email: email,
        password: 'TemporaryPassword123!',
        data: {'role': _selectedRole},
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardScreen(userRole: _selectedRole)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في الاتصال: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تسجيل الحساب', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'البريد الإلكتروني', prefixIcon: const Icon(Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              items: const [
                DropdownMenuItem(value: 'importer', child: Text('مستورد / مسافر')),
                DropdownMenuItem(value: 'investor', child: Text('شريك / مستثمر')),
              ],
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleAuth,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text('تأكيد الحساب عبر Supabase', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final String userRole;
  const DashboardScreen({Key? key, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('لوحة التحكم - ${userRole == 'importer' ? 'مستورد' : 'مستثمر'}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: const Center(child: Text('تم الاتصال بقاعدة البيانات بنجاح! 🎉')),
    );
  }
}
