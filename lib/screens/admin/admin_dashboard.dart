import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../NordenIntroPage.dart';
import 'products_management.dart';
import 'orders_management.dart';
import 'analytics_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  bool _sidebarOpen = false;
  late AnimationController _animationController;

  final List<Widget> _pages = [
    const AdminOverviewPage(),
    const ProductsManagementPage(),
    const OrdersManagementPage(),
    const AnalyticsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF141414), Color(0xFF1A1A1A)],
          ),
        ),
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(isMobile: false),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.02, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: _pages[_selectedIndex],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Column(
          children: [
            _buildMobileHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey(_selectedIndex),
                  child: _pages[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
        if (_sidebarOpen)
          GestureDetector(
            onTap: () => setState(() => _sidebarOpen = false),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _sidebarOpen ? 1.0 : 0.0,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: BackdropFilter(
                  filter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                  child: Container(),
                ),
              ),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: _sidebarOpen ? 0 : -280,
          top: 0,
          bottom: 0,
          child: _buildSidebar(isMobile: true),
        ),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F).withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFFD4AF37),
                  size: 24,
                ),
                onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
              ),
            ),
            const Spacer(),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFD4AF37),
                  Color(0xFFFFF8DC),
                  Color(0xFFD4AF37),
                ],
              ).createShader(bounds),
              child: Text(
                'NORDEN',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(width: 56),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar({required bool isMobile}) {
    final sidebarWidth = 280.0;

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0F0F0F).withOpacity(0.98),
            const Color(0xFF0A0A0A).withOpacity(0.98),
          ],
        ),
        border: Border(
          right: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (!isMobile) ...[
              const SizedBox(height: 32),
              _buildLogo(),
              const SizedBox(height: 56),
            ] else ...[
              const SizedBox(height: 24),
              _buildLogo(),
              const SizedBox(height: 32),
            ],
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Overview',
                    index: 0,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    icon: Icons.inventory_2_rounded,
                    title: 'Products',
                    index: 1,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    icon: Icons.shopping_bag_rounded,
                    title: 'Orders',
                    index: 2,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    icon: Icons.analytics_rounded,
                    title: 'Analytics',
                    index: 3,
                    isMobile: isMobile,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildSignOutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFD4AF37), Color(0xFFFFF8DC), Color(0xFFD4AF37)],
      ).createShader(bounds),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37).withOpacity(0.15),
                  const Color(0xFFD4AF37).withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.diamond_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'NORDEN',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 6,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ADMIN PANEL',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isMobile,
  }) {
    final isSelected = _selectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedIndex = index);
            if (isMobile) {
              setState(() => _sidebarOpen = false);
            }
          },
          borderRadius: BorderRadius.circular(16),
          hoverColor: const Color(0xFFD4AF37).withOpacity(0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFD4AF37).withOpacity(0.25),
                        const Color(0xFFD4AF37).withOpacity(0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: !isSelected ? Colors.transparent : null,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFD4AF37).withOpacity(0.6)
                    : const Color(0xFFD4AF37).withOpacity(0.12),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD4AF37).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFD4AF37).withOpacity(0.5),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFD4AF37).withOpacity(0.65),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await _authService.signOut();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const NordenIntroPage(),
                ),
                (route) => false,
              );
            }
          },
          borderRadius: BorderRadius.circular(14),
          hoverColor: const Color(0xFFFF3B30).withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF3B30).withOpacity(0.1),
                  const Color(0xFFFF3B30).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFF3B30).withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3B30).withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: Color(0xFFFF3B30),
                ),
                const SizedBox(width: 10),
                Text(
                  'Sign Out',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF3B30),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final crossAxisCount = isMobile ? 2 : (width < 1200 ? 3 : 4);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: isMobile ? 28 : 36),
            _buildStatsGrid(context, crossAxisCount),
            SizedBox(height: isMobile ? 36 : 48),
            _buildQuickActions(isMobile),
            SizedBox(height: isMobile ? 24 : 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.2),
                    const Color(0xFFD4AF37).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.dashboard_rounded,
                color: const Color(0xFFD4AF37),
                size: isMobile ? 20 : 24,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFFFF8DC)],
                    ).createShader(bounds),
                    child: Text(
                      'Dashboard Overview',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    'Welcome back, Admin',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFD4AF37).withOpacity(0.6),
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Container(
          height: 3,
          width: isMobile ? 60 : 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFD4AF37),
                Color(0xFFFFF8DC),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, int crossAxisCount) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: isMobile ? 12 : 20,
      mainAxisSpacing: isMobile ? 12 : 20,
      childAspectRatio: isMobile ? 1.2 : 1.4,
      children: [
        _buildStatCard(
          title: 'Total Products',
          value: '0',
          icon: Icons.inventory_2_rounded,
          color: const Color(0xFF4CAF50),
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          ),
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'Total Orders',
          value: '0',
          icon: Icons.shopping_bag_rounded,
          color: const Color(0xFF2196F3),
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
          ),
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'Revenue',
          value: '\$0',
          icon: Icons.payments_rounded,
          color: const Color(0xFFD4AF37),
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFFFF8DC)],
          ),
          isMobile: isMobile,
        ),
        _buildStatCard(
          title: 'Customers',
          value: '0',
          icon: Icons.people_rounded,
          color: const Color(0xFF9C27B0),
          gradient: const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFFAB47BC)],
          ),
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A).withOpacity(0.8),
            const Color(0xFF141414).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: isMobile ? 16 : 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: isMobile ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.25), color.withOpacity(0.15)],
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: isMobile ? 8 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: isMobile ? 20 : 26),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: color,
                      size: isMobile ? 10 : 12,
                    ),
                    SizedBox(width: isMobile ? 3 : 4),
                    Text(
                      '0%',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 9 : 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => gradient.createShader(bounds),
                child: Text(
                  value,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.2),
                    const Color(0xFFD4AF37).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
              ),
              child: Icon(
                Icons.bolt_rounded,
                color: const Color(0xFFD4AF37),
                size: isMobile ? 16 : 20,
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Text(
                'Quick Actions',
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Wrap(
          spacing: isMobile ? 8 : 16,
          runSpacing: isMobile ? 8 : 16,
          children: [
            _buildActionButton(
              title: 'Add Product',
              icon: Icons.add_shopping_cart_rounded,
              onTap: () {},
              color: const Color(0xFF4CAF50),
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              ),
              isMobile: isMobile,
            ),
            _buildActionButton(
              title: 'View Orders',
              icon: Icons.receipt_long_rounded,
              onTap: () {},
              color: const Color(0xFF2196F3),
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
              ),
              isMobile: isMobile,
            ),
            _buildActionButton(
              title: 'Analytics',
              icon: Icons.trending_up_rounded,
              onTap: () {},
              color: const Color(0xFFD4AF37),
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFFFF8DC)],
              ),
              isMobile: isMobile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Gradient gradient,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        hoverColor: color.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 12 : 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: isMobile ? 12 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: isMobile ? 6 : 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isMobile ? 14 : 18,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
