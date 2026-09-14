import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'importer';
  bool _isPhoneMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    if (_isPhoneMode) {
      if (_phoneController.text.isEmpty || _phoneController.text.length < 8) {
        _showError(isArabic ? 'رقم هاتف غير صحيح' : 'Invalid phone number');
        return false;
      }
    } else {
      if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
        _showError(isArabic ? 'بريد إلكتروني غير صحيح' : 'Invalid email');
        return false;
      }
    }

    if (_passwordController.text.isEmpty || _passwordController.text.length < 8) {
      _showError(isArabic ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل' : 'Password must be at least 8 characters');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_validateInputs()) {
      return;
    }

    final identifier =
        _isPhoneMode ? _phoneController.text : _emailController.text;

    await ref.read(authProvider.notifier).signIn(
          identifier: identifier,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      // Keep the existing dashboard providers in sync for presentation only.
      // Supabase/Riverpod authState remains the source of truth.
      final user = authState.user!;
      ref.read(userAuthProvider.notifier).state = <String, String>{
        'identifier': identifier.trim(),
        'role': user.role.value,
      };
      ref.read(userRoleProvider.notifier).state = user.role.value;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } else if (authState.message != null) {
      _showError(authState.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'تسجيل الدخول' : 'Login',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Auth Mode Toggle
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPhoneMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isPhoneMode
                                ? theme.colorScheme.primary
                                : Colors.transparent,
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
                            color: _isPhoneMode
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isArabic ? 'الهاتف' : 'Phone',
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
              const SizedBox(height: 24),

              // Email/Phone Input
              if (!_isPhoneMode)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'user@example.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                  ],
                ),
              if (_isPhoneMode)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'رقم الهاتف' : 'Phone Number',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '+213 555 123 456',
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Password Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'كلمة المرور' : 'Password',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Role Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'نوع الحساب' : 'Account Type',
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
                          value: 'importer',
                          child: Text(
                            isArabic ? 'مستورد / مسافر' : 'Importer / Traveler',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'investor',
                          child: Text(
                            isArabic ? 'شريك استثماري' : 'Investor Partner',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedRole = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(isArabic ? 'دخول' : 'Login'),
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
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      isArabic ? 'إنشاء حساب' : 'Sign Up',
                      style: GoogleFonts.poppins(
                        color: theme.colorScheme.primary,
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
