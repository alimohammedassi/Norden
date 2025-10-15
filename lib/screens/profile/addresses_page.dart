import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/address_service.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final AddressService _addressService = AddressService();

  @override
  void initState() {
    super.initState();
    _addressService.loadAddresses();
    _addressService.addListener(_onAddressesChanged);
  }

  @override
  void dispose() {
    _addressService.removeListener(_onAddressesChanged);
    super.dispose();
  }

  void _onAddressesChanged() {
    if (mounted) {
      setState(() {});
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
                child: _addressService.addresses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 80,
                              color: const Color(0xFFD4AF37).withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Addresses Yet',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFD4AF37).withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first address',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFFD4AF37).withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildAddAddressButton(),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            ..._addressService.addresses.asMap().entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildAddressCard(
                                  entry.value,
                                  entry.key,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildAddAddressButton(),
                          ],
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFD4AF37),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'ADDRESSES',
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

  Widget _buildAddressCard(Map<String, dynamic> address, int index) {
    final isDefault = address['isDefault'] == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault
              ? const Color(0xFFD4AF37)
              : const Color(0xFFD4AF37).withOpacity(0.2),
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          if (isDefault)
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    address['label'] == 'Home'
                        ? Icons.home_outlined
                        : Icons.business_outlined,
                    color: const Color(0xFFD4AF37),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    address['label'] ?? 'Address',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFFD4AF37)),
                onPressed: () => _showAddressOptions(address, index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'DEFAULT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 1,
                ),
              ),
            ),
          const SizedBox(height: 12),
          _buildAddressRow(Icons.person_outline, address['name'] ?? ''),
          const SizedBox(height: 8),
          _buildAddressRow(Icons.location_on_outlined, address['street'] ?? ''),
          const SizedBox(height: 8),
          _buildAddressRow(
            Icons.location_city_outlined,
            '${address['city'] ?? ''}, ${address['country'] ?? ''}',
          ),
          const SizedBox(height: 8),
          _buildAddressRow(Icons.phone_outlined, address['phone'] ?? ''),
        ],
      ),
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

  Widget _buildAddAddressButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _showAddAddressDialog,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.add, color: Color(0xFFD4AF37)),
        label: Text(
          'ADD NEW ADDRESS',
          style: GoogleFonts.playfairDisplay(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: const Color(0xFFD4AF37),
          ),
        ),
      ),
    );
  }

  void _showAddressOptions(Map<String, dynamic> address, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (address['isDefault'] != true)
              ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Color(0xFFD4AF37),
                ),
                title: Text(
                  'Set as Default',
                  style: GoogleFonts.inter(color: const Color(0xFFD4AF37)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _addressService.setDefaultAddress(index);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
              title: Text(
                'Edit Address',
                style: GoogleFonts.inter(color: const Color(0xFFD4AF37)),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddAddressDialog(editAddress: address, editIndex: index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFFF3B30)),
              title: Text(
                'Remove Address',
                style: GoogleFonts.inter(color: const Color(0xFFFF3B30)),
              ),
              onTap: () {
                Navigator.pop(context);
                _addressService.removeAddress(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog({
    Map<String, dynamic>? editAddress,
    int? editIndex,
  }) {
    final isEditing = editAddress != null;
    final labelController = TextEditingController(
      text: editAddress?['label'] ?? '',
    );
    final nameController = TextEditingController(
      text: editAddress?['name'] ?? '',
    );
    final streetController = TextEditingController(
      text: editAddress?['street'] ?? '',
    );
    final cityController = TextEditingController(
      text: editAddress?['city'] ?? '',
    );
    final countryController = TextEditingController(
      text: editAddress?['country'] ?? '',
    );
    final phoneController = TextEditingController(
      text: editAddress?['phone'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        ),
        title: Text(
          isEditing ? 'Edit Address' : 'Add New Address',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFD4AF37),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                controller: labelController,
                label: 'Label',
                hint: 'Home, Work, etc.',
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: nameController,
                label: 'Full Name',
                hint: 'John Doe',
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: streetController,
                label: 'Street Address',
                hint: '123 Main St',
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: cityController,
                label: 'City',
                hint: 'Cairo',
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: countryController,
                label: 'Country',
                hint: 'Egypt',
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: phoneController,
                label: 'Phone Number',
                hint: '+20 123 456 7890',
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  streetController.text.isNotEmpty &&
                  cityController.text.isNotEmpty &&
                  countryController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                final address = {
                  'label': labelController.text.isNotEmpty
                      ? labelController.text
                      : 'Home',
                  'name': nameController.text,
                  'street': streetController.text,
                  'city': cityController.text,
                  'country': countryController.text,
                  'phone': phoneController.text,
                  'isDefault': false,
                };

                if (isEditing && editIndex != null) {
                  // Keep the same default status
                  address['isDefault'] = editAddress['isDefault'] ?? false;
                  await _addressService.updateAddress(editIndex, address);
                } else {
                  await _addressService.addAddress(address);
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Address updated successfully'
                            : 'Address added successfully',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: const Color(0xFF1A1A1A),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please fill all required fields',
                      style: GoogleFonts.inter(),
                    ),
                    backgroundColor: const Color(0xFFFF3B30),
                  ),
                );
              }
            },
            child: Text(
              isEditing ? 'SAVE' : 'ADD ADDRESS',
              style: GoogleFonts.inter(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: const Color(0xFFD4AF37)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(
          color: const Color(0xFFD4AF37).withOpacity(0.7),
        ),
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
        ),
        filled: true,
        fillColor: const Color(0xFF0A0A0A).withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
        ),
      ),
    );
  }
}
