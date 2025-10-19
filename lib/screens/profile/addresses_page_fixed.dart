import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/address_service.dart';
import '../../models/address.dart';
import '../../widgets/simple_map_picker.dart';

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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
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
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first address to get started',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
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
                              child: _buildAddressCard(entry.value, entry.key),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
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
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD4AF37),
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address, int index) {
    final isDefault = address.isDefault;

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
                    address.label == 'Home'
                        ? Icons.home_outlined
                        : Icons.business_outlined,
                    color: const Color(0xFFD4AF37),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    address.label,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                  // TODO: Add latitude/longitude support for Address model
                  // if (address['latitude'] != null &&
                  //     address['longitude'] != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.map,
                    color: const Color(0xFFD4AF37).withOpacity(0.7),
                    size: 16,
                  ),
                  // ],
                  if (isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DEFAULT',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD4AF37),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
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
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 1,
                ),
              ),
            ),
          const SizedBox(height: 12),
          _buildAddressRow(Icons.person_outline, address.name),
          const SizedBox(height: 8),
          _buildAddressRow(Icons.location_on_outlined, address.street),
          const SizedBox(height: 8),
          _buildAddressRow(
            Icons.location_city_outlined,
            '${address.city}, ${address.country}',
          ),
          const SizedBox(height: 8),
          _buildAddressRow(Icons.phone_outlined, address.phone),
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
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37),
            const Color(0xFFD4AF37).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddAddressDialog,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Text(
                  'ADD NEW ADDRESS',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddressOptions(Address address, int index) {
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
            if (!address.isDefault)
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
                  _addressService.setDefaultAddressByIndex(index);
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
                _showEditAddressDialog(address, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Address',
                style: GoogleFonts.inter(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(address, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    _showAddressDialog();
  }

  void _showEditAddressDialog(Address address, int index) {
    _showAddressDialog(isEditing: true, editAddress: address, editIndex: index);
  }

  void _showAddressDialog({
    bool isEditing = false,
    Address? editAddress,
    int? editIndex,
  }) {
    final labelController = TextEditingController(
      text: editAddress?.label ?? '',
    );
    final nameController = TextEditingController(text: editAddress?.name ?? '');
    final phoneController = TextEditingController(
      text: editAddress?.phone ?? '',
    );
    final streetController = TextEditingController(
      text: editAddress?.street ?? '',
    );
    final cityController = TextEditingController(text: editAddress?.city ?? '');
    final countryController = TextEditingController(
      text: editAddress?.country ?? '',
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
            fontSize: 20,
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
                controller: phoneController,
                label: 'Phone Number',
                hint: '+1234567890',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: streetController,
                label: 'Street Address',
                hint: '123 Main Street',
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: cityController,
                label: 'City',
                hint: 'New York',
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: countryController,
                label: 'Country',
                hint: 'United States',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final address = {
                'label': labelController.text.trim(),
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
                'street': streetController.text.trim(),
                'city': cityController.text.trim(),
                'country': countryController.text.trim(),
                'isDefault': isEditing
                    ? (editAddress?.isDefault ?? false)
                    : false,
              };

              try {
                if (isEditing && editIndex != null) {
                  print('Updating address at index $editIndex');
                  await _addressService.updateAddressByIndex(
                    editIndex,
                    Address.fromJson(address),
                  );
                } else {
                  print('Adding new address');
                  await _addressService.addAddressObject(
                    Address.fromJson(address),
                  );
                }

                print('Address saved successfully');

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Address updated successfully!'
                            : 'Address added successfully!',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFFD4AF37),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                print('Error saving address: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error saving address. Please try again.',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isEditing ? 'Update' : 'Add',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.w600,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFFD4AF37),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.4)),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(Address address, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        ),
        title: Text(
          'Delete Address',
          style: GoogleFonts.playfairDisplay(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this address?',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _addressService.removeAddress(index);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Address deleted successfully!',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error deleting address. Please try again.',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
