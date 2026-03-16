import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/backend_order_service.dart';
import '../order_tracking_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage>
    with TickerProviderStateMixin {
  final BackendOrderService _orderService = BackendOrderService();
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  static const _gold = Color(0xFFD4AF37);
  static const _goldDeep = Color(0xFFB8860B);

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    _headerController.forward();
    _loadOrders();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orders = await _orderService.getOrders(limit: 20);
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      default:
        return _gold;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel_rounded;
      case 'processing':
        return Icons.hourglass_empty_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  String _formatDate(dynamic dateValue) {
    try {
      final date = dateValue is String ? DateTime.parse(dateValue) : DateTime.now();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '—';
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '—';
    final num p = price is num ? price : num.tryParse(price.toString()) ?? 0;
    return '\$${p.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF141414), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? _buildLoading()
                    : _error != null
                        ? _buildError()
                        : _orders.isEmpty
                            ? _buildEmptyState()
                            : _buildOrderList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _gold.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: _gold, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'ORDER HISTORY',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      color: _gold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_orders.length} ${_orders.length == 1 ? 'order' : 'orders'}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: _gold.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.refresh_rounded, color: _gold.withOpacity(0.8), size: 18),
              ),
              onPressed: _loadOrders,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_gold),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your orders...',
            style: GoogleFonts.inter(
              color: _gold.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.withOpacity(0.8), size: 48),
            const SizedBox(height: 16),
            Text(
              'Could not load orders',
              style: GoogleFonts.playfairDisplay(
                color: _gold,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: GoogleFonts.inter(fontSize: 12, color: _gold.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_gold.withOpacity(0.2), _gold.withOpacity(0.0)],
              ),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: _gold.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Orders Yet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _gold.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Your order history will appear here after you make a purchase',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: _gold.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return RefreshIndicator(
      color: _gold,
      backgroundColor: const Color(0xFF1A1A1A),
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        physics: const BouncingScrollPhysics(),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 60)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: _buildOrderCard(_orders[index]),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id']?.toString() ?? order['_id']?.toString() ?? '—';
    final shortId = orderId.length > 8 ? '#${orderId.substring(orderId.length - 8).toUpperCase()}' : '#$orderId';
    final status = (order['status'] ?? order['orderStatus'] ?? 'pending').toString();
    final totalPrice = order['totalPrice'] ?? order['total'] ?? order['totalAmount'];
    final createdAt = order['createdAt'];
    final items = order['items'] as List<dynamic>? ?? order['orderItems'] as List<dynamic>? ?? [];
    final statusColor = _statusColor(status);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingPage(orderId: orderId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _gold.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top row: Order ID + status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gold.withOpacity(0.15)),
                    ),
                    child: Icon(Icons.receipt_long_outlined, color: _gold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shortId,
                          style: GoogleFonts.dmMono(
                            color: _gold,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          _formatDate(createdAt),
                          style: GoogleFonts.inter(
                            color: _gold.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(status), color: statusColor, size: 12),
                        const SizedBox(width: 5),
                        Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: GoogleFonts.inter(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 12),
                color: _gold.withOpacity(0.08),
              ),

              // Bottom row: Items count + price + track button
              Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, color: _gold.withOpacity(0.5), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                    style: GoogleFonts.inter(
                      color: _gold.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatPrice(totalPrice),
                    style: GoogleFonts.playfairDisplay(
                      color: _gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_gold, _goldDeep]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Track',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
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
