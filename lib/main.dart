import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TradesyncAiApp()));
}

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
  final _phoneController = TextEditingController();
  String _selectedRole = 'importer'; 
  bool _isPhoneMode = false;
  bool _isLogin = true; 

  void _handleAuthentication() {
    final input = _isPhoneMode ? _phoneController.text.trim() : _emailController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('الرجاء إدخال بيانات صحيحة', style: GoogleFonts.poppins())));
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DashboardScreen(userRole: _selectedRole)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء حساب', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () => setState(() => _isLogin = true), child: Text('تسجيل الدخول', style: GoogleFonts.poppins(fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal))),
                TextButton(onPressed: () => setState(() => _isLogin = false), child: Text('إنشاء حساب', style: GoogleFonts.poppins(fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal))),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _isPhoneMode ? _phoneController : _emailController,
              decoration: InputDecoration(hintText: _isPhoneMode ? '+213 555...' : 'البريد الإلكتروني', prefixIcon: Icon(_isPhoneMode ? Icons.phone : Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              keyboardType: _isPhoneMode ? TextInputType.phone : TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: () => setState(() => _isPhoneMode = !_isPhoneMode), child: Text(_isPhoneMode ? 'استخدام البريد الإلكتروني بدلاً من ذلك' : 'استخدام رقم الهاتف بدلاً من ذلك')),
            const SizedBox(height: 24),
            if (!_isLogin) ...[
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                items: const [DropdownMenuItem(value: 'importer', child: Text('مستورد / مسافر')), DropdownMenuItem(value: 'investor', child: Text('شريك / مستثمر'))],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 32),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _handleAuthentication, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(_isLogin ? 'دخول' : 'تأكيد الحساب', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16))),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  final String userRole;
  const DashboardScreen({Key? key, required this.userRole}) : super(key: key);
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> screens = [_buildCollaborationFeed(theme), _buildMarketplaceFeed(), _buildProfileScreen(theme)];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: theme.colorScheme.secondary.withOpacity(0.3),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.handshake_outlined), selectedIcon: Icon(Icons.handshake), label: 'الشراكات'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'السوق'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

  Widget _buildCollaborationFeed(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(title: Text('الشركاء المتاحون', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), floating: true, centerTitle: true),
        SliverPadding(padding: const EdgeInsets.all(16.0), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => _buildCard(theme), childCount: 3))),
      ],
    );
  }

  Widget _buildCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(children: [CircleAvatar(backgroundColor: theme.primaryColor, child: const Icon(Icons.person, color: Colors.white)), const SizedBox(width: 12), Text('شريك محتمل', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16))]),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.handshake), label: Text('طلب شراكة', style: GoogleFonts.poppins()))
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplaceFeed() => Scaffold(appBar: AppBar(title: Text('السوق', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))), body: const Center(child: Text('السوق قيد التطوير')));

  Widget _buildProfileScreen(ThemeData theme) => SafeArea(child: Center(child: Text('حسابي', style: GoogleFonts.poppins(fontSize: 24))));
}
