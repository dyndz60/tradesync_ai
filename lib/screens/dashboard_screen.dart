import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final List<Widget> screens = [
      _buildCollaborationFeed(theme),
      _buildMarketplaceFeed(theme),
      _buildProfileScreen(theme),
    ];

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

  // 1. Collaboration & Matching Logic Tab
  Widget _buildCollaborationFeed(ThemeData theme) {
    // Dynamically show the opposite of the user's role to match them
    final isLookingForInvestors = widget.userRole == 'importer';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(isLookingForInvestors ? 'شركاء سيولة متاحون' : 'مستوردون متاحون (بالكيلو)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          floating: true,
          centerTitle: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (isLookingForInvestors) {
                  return _buildInvestorCard(theme);
                } else {
                  return _buildImporterCard(theme, index);
                }
              },
              childCount: 4, // Mock dynamic list
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImporterCard(ThemeData theme, int index) {
    final locations = ['الصين (Guangzhou)', 'تركيا (Istanbul)', 'الإمارات (Dubai)', 'مصر (Cairo)'];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: theme.primaryColor, child: const Icon(Icons.flight_takeoff, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('مسافر / مستورد موثوق', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('متواجد في: ${locations[index % 4]}', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: theme.colorScheme.tertiary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('المقاول الذاتي', style: GoogleFonts.poppins(color: theme.colorScheme.tertiary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn('السعة المتاحة', '150 كغ', theme),
                _infoColumn('عمولة الاستيراد', '1200 دج/كغ', theme, highlight: true),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
                    icon: const Icon(Icons.handshake, color: Colors.white),
                    label: Text('طلب شراكة', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.chat, color: theme.primaryColor),
                  style: IconButton.styleFrom(side: BorderSide(color: theme.primaryColor.withOpacity(0.2))),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInvestorCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: theme.colorScheme.secondary, child: const Icon(Icons.monetization_on, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('شريك سيولة / مستثمر', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('الجزائر العاصمة', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn('السيولة المتاحة', '500,000 دج - 2,000,000 دج', theme, highlight: true),
                _infoColumn('المجال', 'إلكترونيات، ملابس', theme),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text('بدء محادثة للتمويل', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 2. Traditional Wholesale Marketplace Tab
  Widget _buildMarketplaceFeed(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(title: Text('سوق الجملة', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), centerTitle: true),
      body: Center(child: Text('تغذية المنتجات تأتي هنا (Products Feed)', style: GoogleFonts.poppins(color: Colors.grey))),
    );
  }

  // 3. User Profile & Verification Tab
  Widget _buildProfileScreen(ThemeData theme) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          CircleAvatar(radius: 50, backgroundColor: theme.primaryColor, child: const Icon(Icons.person, size: 50, color: Colors.white)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.userRole == 'importer' ? 'مستورد مسافر' : 'مستثمر محلي',
              style: GoogleFonts.poppins(fontSize: 18, color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.primaryColor.withOpacity(0.2))),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.badge, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text('توثيق المقاول الذاتي', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('ارفع نسخة من بطاقتك لزيادة الموثوقية لدى الشركاء.', style: GoogleFonts.poppins(fontSize: 12)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file),
                      label: Text('رفع البطاقة', style: GoogleFonts.poppins()),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value, ThemeData theme, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: highlight ? theme.colorScheme.secondary : Colors.black,
          ),
        ),
      ],
    );
  }
}
