import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_models.dart';
import '../models/app_user.dart';
import '../providers/app_providers.dart';
import 'dashboard_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'importer';
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    if (_nameController.text.isEmpty) {
      _showError(isArabic ? 'الرجاء إدخال الاسم' : 'Please enter your name');
      return false;
    }

    if (_emailController.text.trim().isEmpty &&
        _phoneController.text.trim().isEmpty) {
      _showError(
        isArabic
            ? 'أدخل البريد الإلكتروني أو رقم الهاتف'
            : 'Enter an email or phone number',
      );
      return false;
    }

    if (_passwordController.text.length < 8) {
      _showError(isArabic ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل' : 'Password must be at least 8 characters');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError(isArabic ? 'كلمات المرور غير متطابقة' : 'Passwords do not match');
      return false;
    }

    if (!_agreedToTerms) {
      _showError(isArabic ? 'الرجاء الموافقة على الشروط والأحكام' : 'Please agree to terms and conditions');
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

  Future<void> _handleSignup() async {
    if (!_validateInputs()) {
      return;
    }

    final role = UserRoleX.tryParse(_selectedRole);
    if (role == null) {
      _showError('نوع الحساب غير صالح');
      return;
    }

    final identifier = _emailController.text.trim().isNotEmpty
        ? _emailController.text
        : _phoneController.text;

    await ref.read(authProvider.notifier).signUp(
          identifier: identifier,
          password: _passwordController.text,
          role: role,
          isAutoEntrepreneur: false,
          phone: _phoneController.text,
        );

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      final user = authState.user!;
      ref.read(userAuthProvider.notifier).state = <String, String>{
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'role': user.role.value,
      };
      ref.read(userRoleProvider.notifier).state = user.role.value;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } else if (authState.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authState.message!,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
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
          isArabic ? 'إنشاء حساب' : 'Sign Up',
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

              // Name Input
              Text(
                isArabic ? 'الاسم الكامل' : 'Full Name',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: isArabic ? 'أحمد محمد' : 'John Doe',
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Email Input
              Text(
                isArabic ? 'البريد الإلكتروني' : 'Email',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
              const SizedBox(height: 16),

              // Phone Input
              Text(
                isArabic ? 'رقم الهاتف' : 'Phone Number',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
              const SizedBox(height: 16),

              // Role Selection
              Text(
                isArabic ? 'نوع الحساب' : 'Account Type',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
              const SizedBox(height: 16),

              // Password Input
              Text(
                isArabic ? 'كلمة المرور' : 'Password',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
              const SizedBox(height: 16),

              // Confirm Password Input
              Text(
                isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Terms Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() => _agreedToTerms = value ?? false);
                    },
                  ),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'أوافق على الشروط والأحكام'
                          : 'I agree to Terms and Conditions',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Signup Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSignup,
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
                      : Text(isArabic ? 'إنشاء حساب' : 'Create Account'),
                ),
              ),
              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isArabic ? 'لديك حساب بالفعل؟ ' : 'Already have an account? ',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      isArabic ? 'دخول' : 'Login',
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
