import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_models.dart';
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
  
  String _selectedRole = 'retailBuyer';
  bool _isLoading = false;
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

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError(isArabic ? 'بريد إلكتروني غير صحيح' : 'Invalid email');
      return false;
    }

    if (_phoneController.text.isEmpty || _phoneController.text.length < 8) {
      _showError(isArabic ? 'رقم هاتف غير صحيح' : 'Invalid phone number');
      return false;
    }

    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _showError(isArabic ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : 'Password must be at least 6 characters');
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

  void _handleSignup() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual Supabase signup
      await Future.delayed(const Duration(milliseconds: 800));

      // Store auth state
      ref.read(userAuthProvider.notifier).state = {
        'email': _emailController.text,
        'name': _nameController.text,
        'role': _selectedRole,
      };
      ref.read(userRoleProvider.notifier).state = _selectedRole;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'تم إنشاء الحساب بنجاح'
                  : 'Account created successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      _showError('Signup failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

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
                    DropdownMenuItem(
                      value: 'retailBuyer',
                      child: Text(
                        isArabic ? 'مشتري تجزئة' : 'Retail Buyer',
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
                  onPressed: _isLoading ? null : _handleSignup,
                  child: _isLoading
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
