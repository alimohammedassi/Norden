import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cart_service.dart';
import '../services/address_service.dart';
import '../models/address.dart';
import 'profile/addresses_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartService _cartService = CartService();
  final AddressService _addressService = AddressService();

  Address? _selectedAddress;
  int _selectedPaymentMethod = 0; // 0: Card, 1: Cash on Delivery
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _addressService.loadAddresses();
    _addressService.addListener(_onAddressesChanged);
    // Set default address
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedAddress = _addressService.defaultAddress;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _addressService.removeListener(_onAddressesChanged);
    super.dispose();
  }

  void _onAddressesChanged() {
    if (mounted) {
      setState(() {
        _selectedAddress = _addressService.defaultAddress;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a delivery address',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate order processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);
      _cartService.clear();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildSuccessDialog(),
      );
    }
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
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF141414),
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddressSection(),
                      const SizedBox(height: 24),
                      _buildPaymentSection(),
                      const SizedBox(height: 24),
                      _buildOrderSummary(),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFD4AF37),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'CHECKOUT',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: const Color(0xFFD4AF37),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DELIVERY ADDRESS',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD4AF37),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedAddress != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedAddress!.label,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddressesPage(),
                          ),
                        );
                      },
                      child: Text(
                        'CHANGE',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD4AF37),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAddressRow(Icons.person_outline, _selectedAddress!.name),
                const SizedBox(height: 8),
                _buildAddressRow(
                  Icons.location_on_outlined,
                  _selectedAddress!.street,
                ),
                const SizedBox(height: 8),
                _buildAddressRow(
                  Icons.location_city_outlined,
                  '${_selectedAddress!.city}, ${_selectedAddress!.country}',
                ),
                const SizedBox(height: 8),
                _buildAddressRow(Icons.phone_outlined, _selectedAddress!.phone),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF3B30).withOpacity(0.5),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.location_off_outlined,
                  color: const Color(0xFFFF3B30),
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Address Selected',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF3B30),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please add a delivery address',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFFD4AF37).withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddressesPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: const Color(0xFFD4AF37).withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.add, color: Color(0xFFD4AF37)),
                    label: Text(
                      'ADD ADDRESS',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD4AF37),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAddressRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37).withOpacity(0.5), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFFD4AF37).withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT METHOD',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD4AF37),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        _buildPaymentOption(
          index: 0,
          icon: Icons.credit_card,
          title: 'Credit / Debit Card',
          subtitle: 'Pay securely with your card',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          index: 1,
          icon: Icons.attach_money,
          title: 'Cash on Delivery',
          subtitle: 'Pay when you receive',
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4AF37)
                : const Color(0xFFD4AF37).withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFD4AF37).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFD4AF37),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final subtotal = _cartService.subtotal;
    final shipping = 10.0;
    final tax = subtotal * 0.1;
    final total = subtotal + shipping + tax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER SUMMARY',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD4AF37),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              _buildSummaryRow('Shipping', '\$${shipping.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              _buildSummaryRow('Tax (10%)', '\$${tax.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: const Color(0xFFD4AF37).withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow(
                'Total',
                '\$${total.toStringAsFixed(2)}',
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFFD4AF37).withOpacity(isTotal ? 1.0 : 0.7),
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.playfairDisplay(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD4AF37),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          top: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              alignment: Alignment.center,
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      'PLACE ORDER',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessDialog() {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFD4AF37),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.black, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'Order Placed!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your order has been placed successfully',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFFD4AF37).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: Text(
                    'CONTINUE SHOPPING',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
