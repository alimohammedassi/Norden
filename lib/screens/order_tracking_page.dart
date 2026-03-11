import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import 'profile/customer_service_page.dart';
import '../providers/season_provider.dart';
import '../config/app_theme.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  const OrderTrackingPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> with SingleTickerProviderStateMixin {
  SeasonTokens get t => SeasonScope.of(context).tokens;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final AddressService _addressService = AddressService();
  Address? _currentAddress;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Order Placed',
      'subtitle': 'Your order has been received',
      'icon': Icons.receipt_long_rounded,
      'status': 'completed',
      'time': '10:30 AM',
    },
    {
      'title': 'Preparing',
      'subtitle': 'We are preparing your elegant pieces',
      'icon': Icons.inventory_2_outlined,
      'status': 'completed',
      'time': '10:45 AM',
    },
    {
      'title': 'Out for Delivery',
      'subtitle': 'Your package is on its way to you',
      'icon': Icons.local_shipping_outlined,
      'status': 'active',
      'time': '11:15 AM',
    },
    {
      'title': 'Delivered',
      'subtitle': 'Package handed over to recipient',
      'icon': Icons.check_circle_outline_rounded,
      'status': 'pending',
      'time': '--:--',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAddress();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  Future<void> _loadAddress() async {
    await _addressService.loadAddresses();
    if (mounted) {
      setState(() {
        _currentAddress = _addressService.defaultAddress;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: t.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              t.bg,
              t.surface2,
              t.surface,
              t.surface2,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderInfo(),
                        const SizedBox(height: 32),
                        _buildTrackingSteps(),
                        const SizedBox(height: 40),
                        _buildDeliveryAddress(),
                        const SizedBox(height: 40),
                        _buildOrderSummary(),
                        const SizedBox(height: 40),
                        _buildNeedHelp(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: t.gold),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'TRACK ORDER',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: t.gold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.gold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID: ${widget.orderId}',
                  style: GoogleFonts.inter(
                    color: t.gold.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estimated Delivery',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today, 12:30 PM - 01:30 PM',
                  style: GoogleFonts.inter(
                    color: t.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.access_time_filled_rounded, color: t.gold, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER PROGRESS',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: t.gold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _steps.length,
          itemBuilder: (context, index) {
            final step = _steps[index];
            final bool isCompleted = step['status'] == 'completed';
            final bool isActive = step['status'] == 'active';
            final bool isLast = index == _steps.length - 1;

            return IntrinsicHeight(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted || isActive 
                              ? t.gold 
                              : t.surface,
                          border: Border.all(
                            color: t.gold.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : step['icon'],
                          color: isCompleted || isActive ? Colors.black : t.gold.withOpacity(0.3),
                          size: 16,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: isCompleted 
                                ? t.gold 
                                : t.gold.withOpacity(0.1),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                step['title'],
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isCompleted || isActive ? Colors.white : Colors.white.withOpacity(0.3),
                                ),
                              ),
                              Text(
                                step['time'],
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isCompleted || isActive 
                                      ? t.gold 
                                      : t.gold.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step['subtitle'],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isCompleted || isActive 
                                  ? Colors.white.withOpacity(0.6) 
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DELIVERY LOCATION',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: t.gold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.gold.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_on_rounded, color: t.gold, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentAddress?.label ?? 'Delivery Address',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentAddress != null
                          ? '${_currentAddress!.street}, ${_currentAddress!.city}, ${_currentAddress!.country}'
                          : 'Location not set',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER SUMMARY',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: t.gold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: t.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.gold.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildSummaryItem('Premium Wool Coat', '1x', '\$499.00'),
              const SizedBox(height: 12),
              _buildSummaryItem('Silk Evening Scarf', '1x', '\$85.00'),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Color(0x22D4AF37), height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '\$584.00',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: t.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.credit_card, size: 14, color: t.gold),
                  const SizedBox(width: 8),
                  Text(
                    'Paid via Visa ending in 4242',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String name, String qty, String price) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        Text(
          qty,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          price,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNeedHelp() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.gold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Need help with your order?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomerServicePage()),
              );
            },
            child: Text(
              'CONTACT SUPPORT',
              style: GoogleFonts.playfairDisplay(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: t.gold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
