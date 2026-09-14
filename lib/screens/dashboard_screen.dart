import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_models.dart';
import 'calculator_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final userRole = ref.watch(userRoleProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TradeSync AI',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          // Marketplace Feed
          MarketplaceFeedTab(isArabic: isArabic, userRole: userRole),
          
          // Collaboration Matching
          CollaborationMatchingTab(isArabic: isArabic, userRole: userRole),
          
          // Calculator
          const CalculatorScreen(),
          
          // Chat/Messages
          MessagesTab(isArabic: isArabic),
          
          // Profile
          ProfileTab(isArabic: isArabic),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) => setState(() => _selectedTabIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.storefront),
            label: isArabic ? 'السوق' : 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: isArabic ? 'شركاء' : 'Partners',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calculate),
            label: isArabic ? 'حاسبة' : 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: isArabic ? 'رسائل' : 'Messages',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: isArabic ? 'الملف' : 'Profile',
          ),
        ],
      ),
    );
  }
}

// Marketplace Feed Tab
class MarketplaceFeedTab extends StatelessWidget {
  final bool isArabic;
  final String? userRole;

  const MarketplaceFeedTab({
    required this.isArabic,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Header
        Text(
          isArabic ? 'سوق الاستيراد' : 'Import Marketplace',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        // Sample Import Listings
        _buildImportCard(
          context: context,
          title: isArabic ? 'الملابس من تركيا' : 'Clothing from Turkey',
          supplier: 'Ahmed Mohammed',
          location: 'تركيا - Turkey',
          pricePerKg: 45.50,
          minimumKg: 50,
          commission: 80,
          image: '👔',
          isArabic: isArabic,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildImportCard(
          context: context,
          title: isArabic ? 'إلكترونيات من الصين' : 'Electronics from China',
          supplier: 'Fatima Chen',
          location: 'الصين - China',
          pricePerKg: 120.00,
          minimumKg: 100,
          commission: 150,
          image: '📱',
          isArabic: isArabic,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildImportCard(
          context: context,
          title: isArabic ? 'مواد غذائية من مصر' : 'Food from Egypt',
          supplier: 'Mohammed Samir',
          location: 'مصر - Egypt',
          pricePerKg: 25.00,
          minimumKg: 200,
          commission: 40,
          image: '🍞',
          isArabic: isArabic,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildImportCard({
    required BuildContext context,
    required String title,
    required String supplier,
    required String location,
    required double pricePerKg,
    required int minimumKg,
    required double commission,
    required String image,
    required bool isArabic,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(image, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        supplier,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(location, style: GoogleFonts.poppins(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'السعر/كيلو' : 'Price/kg',
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      Text(
                        '${pricePerKg.toStringAsFixed(2)} USD',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'الحد الأدنى' : 'Min',
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      Text(
                        '$minimumKg kg',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'العمولة' : 'Commission',
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      Text(
                        '${commission.toStringAsFixed(0)} دج',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: Text(isArabic ? 'محادثة' : 'Chat'),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: Text(isArabic ? 'اهتمام' : 'Interested'),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Collaboration Matching Tab
class CollaborationMatchingTab extends StatelessWidget {
  final bool isArabic;
  final String? userRole;

  const CollaborationMatchingTab({
    required this.isArabic,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Header
        Text(
          isArabic ? 'البحث عن شركاء' : 'Find Partners',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          isArabic
              ? 'ابحث عن شركاء يناسبون احتياجاتك'
              : 'Find partners that match your needs',
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 16),

        // Filter Section
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.filter_list),
                label: Text(isArabic ? 'تصفية' : 'Filter'),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.search),
                label: Text(isArabic ? 'بحث' : 'Search'),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Partner Cards
        _buildPartnerCard(
          context: context,
          name: 'علي محمد',
          role: isArabic ? 'مستورد من تركيا' : 'Importer from Turkey',
          badge: '✓ Verified',
          commission: 100,
          capacity: 500,
          location: 'تركيا',
          image: '👨‍💼',
          isArabic: isArabic,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildPartnerCard(
          context: context,
          name: 'فاطمة حسن',
          role: isArabic ? 'شريك استثماري' : 'Investment Partner',
          badge: '✓ Verified',
          commission: 150000,
          capacity: 1000,
          location: 'الجزائر',
          image: '👩‍💼',
          isArabic: isArabic,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildPartnerCard(
          context: context,
          name: 'محمد صادق',
          role: isArabic ? 'مسافر من الإمارات' : 'Traveler from UAE',
          badge: '✓ Verified',
          commission: 200,
          capacity: 2000,
          location: 'الإمارات',
          image: '✈️',
          isArabic: isArabic,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildPartnerCard({
    required BuildContext context,
    required String name,
    required String role,
    required String badge,
    required double commission,
    required int capacity,
    required String location,
    required String image,
    required bool isArabic,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(image, style: const TextStyle(fontSize: 50)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.labelLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: theme.colorScheme.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(location, style: GoogleFonts.poppins(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'العمولة' : 'Commission',
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      Text(
                        commission < 1000
                            ? '${commission.toStringAsFixed(0)} دج/kg'
                            : '${(commission / 1000).toStringAsFixed(0)}k دج',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'السعة' : 'Capacity',
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      Text(
                        '$capacity kg',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: Text(isArabic ? 'محادثة' : 'Message'),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.handshake),
                    label: Text(isArabic ? 'تعاون' : 'Collaborate'),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Messages Tab
class MessagesTab extends StatelessWidget {
  final bool isArabic;

  const MessagesTab({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        isArabic ? 'الرسائل قريباً' : 'Messages Coming Soon',
        style: GoogleFonts.poppins(),
      ),
    );
  }
}

// Profile Tab
class ProfileTab extends StatelessWidget {
  final bool isArabic;

  const ProfileTab({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_circle,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'أحمد محمد',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic ? 'مستورد من تركيا' : 'Importer from Turkey',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '✓ Verified Self-Entrepreneur',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Settings
        ListTile(
          leading: const Icon(Icons.edit),
          title: Text(isArabic ? 'تعديل الملف' : 'Edit Profile'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: Text(isArabic ? 'الأمان' : 'Security'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(isArabic ? 'الإعدادات' : 'Settings'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: Text(isArabic ? 'المساعدة' : 'Help'),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(
            isArabic ? 'تسجيل الخروج' : 'Logout',
            style: const TextStyle(color: Colors.red),
          ),
          onTap: () {
            // Handle logout
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
