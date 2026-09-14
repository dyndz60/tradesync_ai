import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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

class TradesyncAiApp extends StatelessWidget {
  const TradesyncAiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradeSync AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      // Configure localization for Arabic (Algeria - ar-DZ)
      locale: const Locale('ar', 'DZ'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'DZ'),  // Arabic - Algeria
        Locale('en', 'US'),  // English - United States
      ],
      // Enable RTL for Arabic
      builder: (context, child) {
        return Directionality(
          textDirection: _getTextDirection(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const WelcomeScreen(),
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

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'TradeSync AI' : 'TradeSync AI',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isArabic ? 'مرحبا بك في TradeSync AI' : 'Welcome to TradeSync AI',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'منصة التجارة الجملة الجزائرية'
                    : 'Algerian Wholesale Platform',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Text(
                isArabic
                    ? 'تبادل البضائع والخدمات بسهولة وأمان'
                    : 'Exchange goods and services with ease and security',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AuthScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isArabic ? 'ابدأ الآن' : 'Get Started',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _selectedRole = 'retailBuyer';
  bool _isPhoneMode = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    if (_isPhoneMode) {
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'الرجاء إدخال رقم الهاتف' : 'Please enter a phone number',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
        return;
      }
    } else {
      if (_emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'الرجاء إدخال البريد الإلكتروني' : 'Please enter an email',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
        return;
      }
    }

    // Successfully logged in - navigate to marketplace
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'تم تسجيل الدخول بنجاح' : 'Login successful',
          style: GoogleFonts.poppins(),
        ),
      ),
    );

    // Navigate to marketplace or dashboard
    // For now, just show a confirmation
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'تسجيل الدخول' : 'Login',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                isArabic ? 'اختر طريقة التسجيل' : 'Choose login method',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Authentication Mode Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPhoneMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isPhoneMode ? Colors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isArabic ? 'البريد الإلكتروني' : 'Email',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: !_isPhoneMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPhoneMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isPhoneMode ? Colors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isArabic ? 'رقم الهاتف' : 'Phone',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: _isPhoneMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Email Input
              if (!_isPhoneMode) ...[
                Text(
                  isArabic ? 'البريد الإلكتروني' : 'Email Address',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: isArabic ? 'البريد الإلكتروني' : 'Enter your email',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],

              // Phone Input
              if (_isPhoneMode) ...[
                Text(
                  isArabic ? 'رقم الهاتف الجزائري' : 'Algerian Phone Number',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: '+213 555 12 34 56',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.phone_outlined),
                    prefixText: '+213 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
              const SizedBox(height: 24),

              // Role Selection
              Text(
                isArabic ? 'اختر دورك' : 'Select your role',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: [
                    DropdownMenuItem(
                      value: 'wholesaleSeller',
                      child: Text(
                        isArabic ? 'بائع جملة' : 'Wholesale Seller',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'retailBuyer',
                      child: Text(
                        isArabic ? 'مشتري تجزئة' : 'Retail Buyer',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedRole = value ?? 'retailBuyer');
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isArabic ? 'دخول' : 'Login',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isArabic ? 'ليس لديك حساب؟ ' : "Don't have an account? ",
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      isArabic ? 'إنشاء حساب' : 'Sign Up',
                      style: GoogleFonts.poppins(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
