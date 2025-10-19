import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/image_storage_service.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final ImageStorageService _imageService = ImageStorageService();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  // Selected values
  String _selectedCategory = 'Coats';
  final List<String> _selectedColors = [];
  final List<String> _selectedSizes = [];
  bool _isNew = false;
  bool _isFeatured = false;
  bool _isLoading = false;

  // Image uploads
  final List<XFile> _selectedImages = [];
  String _uploadProgress = '';

  // Animation
  late AnimationController _animationController;
  Animation<double>? _fadeAnimation;

  // Available options
  final List<String> _categories = [
    'Coats',
    'Jackets',
    'Sweaters',
    'Blazers',
    'Accessories',
  ];

  final List<String> _availableColors = [
    'Black',
    'Navy',
    'Gray',
    'Brown',
    'Beige',
    'White',
  ];

  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 650, maxHeight: 720),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F0F0F).withOpacity(0.98),
                  const Color(0xFF0A0A0A).withOpacity(0.98),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Product Name',
                            hint: 'Enter product name',
                            icon: Icons.shopping_bag_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter product name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            hint: 'Enter product description',
                            icon: Icons.description_rounded,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _priceController,
                                  label: 'Price (\$)',
                                  hint: '0.00',
                                  icon: Icons.payments_rounded,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter price';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Please enter valid price';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _stockController,
                                  label: 'Stock',
                                  hint: '0',
                                  icon: Icons.inventory_rounded,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter stock';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Please enter valid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildCategoryDropdown(),
                          const SizedBox(height: 20),
                          _buildColorSelector(),
                          const SizedBox(height: 20),
                          _buildSizeSelector(),
                          const SizedBox(height: 20),
                          _buildCheckboxes(),
                          const SizedBox(height: 20),
                          _buildImageUploader(),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_uploadProgress.isNotEmpty) _buildUploadProgress(),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.1),
            const Color(0xFFD4AF37).withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37).withOpacity(0.3),
                  const Color(0xFFD4AF37).withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_shopping_cart_rounded,
              color: Color(0xFFD4AF37),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFFFF8DC)],
                  ).createShader(bounds),
                  child: Text(
                    'Add New Product',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fill in the details below',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFD4AF37).withOpacity(0.6),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              color: const Color(0xFFD4AF37).withOpacity(0.7),
              iconSize: 20,
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFFD4AF37).withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4AF37),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(
            color: const Color(0xFFD4AF37),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFF1A1A1A).withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFFD4AF37).withOpacity(0.25),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3B30),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category_rounded,
              size: 16,
              color: const Color(0xFFD4AF37).withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              'Category',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4AF37),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            dropdownColor: const Color(0xFF1A1A1A),
            style: GoogleFonts.inter(
              color: const Color(0xFFD4AF37),
              fontSize: 14,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFD4AF37),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1A1A1A).withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFD4AF37).withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD4AF37),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(category),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.palette_rounded,
              size: 16,
              color: const Color(0xFFD4AF37).withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              'Colors',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4AF37),
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                ),
              ),
              child: Text(
                '${_selectedColors.length} selected',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableColors.map((color) {
            final isSelected = _selectedColors.contains(color);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                label: Text(color),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedColors.add(color);
                    } else {
                      _selectedColors.remove(color);
                    }
                  });
                },
                backgroundColor: const Color(0xFF1A1A1A).withOpacity(0.7),
                selectedColor: const Color(0xFFD4AF37).withOpacity(0.25),
                checkmarkColor: const Color(0xFFD4AF37),
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFD4AF37).withOpacity(0.6),
                ),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFD4AF37).withOpacity(0.25),
                  width: isSelected ? 1.5 : 1,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.straighten_rounded,
              size: 16,
              color: const Color(0xFFD4AF37).withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              'Sizes',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4AF37),
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                ),
              ),
              child: Text(
                '${_selectedSizes.length} selected',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableSizes.map((size) {
            final isSelected = _selectedSizes.contains(size);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                label: Text(size),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSizes.add(size);
                    } else {
                      _selectedSizes.remove(size);
                    }
                  });
                },
                backgroundColor: const Color(0xFF1A1A1A).withOpacity(0.7),
                selectedColor: const Color(0xFFD4AF37).withOpacity(0.25),
                checkmarkColor: const Color(0xFFD4AF37),
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFD4AF37).withOpacity(0.6),
                ),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFD4AF37).withOpacity(0.25),
                  width: isSelected ? 1.5 : 1,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCheckboxes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildCheckbox(
            title: 'Mark as NEW',
            subtitle: 'Display "NEW" badge on product',
            value: _isNew,
            icon: Icons.fiber_new_rounded,
            onChanged: (value) => setState(() => _isNew = value ?? false),
          ),
          const SizedBox(height: 12),
          _buildCheckbox(
            title: 'Mark as FEATURED',
            subtitle: 'Show in featured section',
            value: _isFeatured,
            icon: Icons.star_rounded,
            onChanged: (value) => setState(() => _isFeatured = value ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool?> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: value
                ? const Color(0xFFD4AF37).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value
                  ? const Color(0xFFD4AF37).withOpacity(0.4)
                  : const Color(0xFFD4AF37).withOpacity(0.15),
              width: value ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: value
                      ? const Color(0xFFD4AF37).withOpacity(0.2)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: value
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFD4AF37).withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: value
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFFD4AF37).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFFD4AF37).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFFD4AF37),
                checkColor: Colors.black,
                side: BorderSide(
                  color: const Color(0xFFD4AF37).withOpacity(0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library_rounded,
              size: 16,
              color: const Color(0xFFD4AF37).withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              'Product Images',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4AF37),
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _selectedImages.isEmpty
                    ? const Color(0xFFFF3B30).withOpacity(0.15)
                    : const Color(0xFF4CAF50).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedImages.isEmpty
                      ? const Color(0xFFFF3B30).withOpacity(0.3)
                      : const Color(0xFF4CAF50).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedImages.isEmpty
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_rounded,
                    size: 12,
                    color: _selectedImages.isEmpty
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_selectedImages.length} image${_selectedImages.length != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _selectedImages.isEmpty
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _pickImages,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.4),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD4AF37).withOpacity(0.2),
                          const Color(0xFFD4AF37).withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_rounded,
                      size: 32,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upload Product Images',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Click to select images',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.9),
        border: Border(
          top: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFD4AF37),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _uploadProgress,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFFD4AF37).withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                  ),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD4AF37).withOpacity(0.7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Add Product',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one image'),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
      return;
    }

    if (_selectedColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one color'),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
      return;
    }

    if (_selectedSizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one size'),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 'Uploading images...';
    });

    try {
      // Generate a temporary product ID for image uploads
      final String tempProductId =
          'temp_${DateTime.now().millisecondsSinceEpoch}';

      // Upload images
      final List<String> imageUrls = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        setState(() {
          _uploadProgress =
              'Uploading image ${i + 1} of ${_selectedImages.length}...';
        });

        final String? imageUrl = await _imageService.uploadImage(
          _selectedImages[i],
          tempProductId,
        );

        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }

      if (imageUrls.isEmpty) {
        throw Exception('Failed to upload images');
      }

      setState(() {
        _uploadProgress = 'Creating product...';
      });

      // Create product
      final product = Product(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory,
        images: imageUrls,
        colors: _selectedColors,
        sizes: _selectedSizes,
        stock: int.parse(_stockController.text.trim()),
        isNew: _isNew,
        isFeatured: _isFeatured,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _productService.addProduct(product);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product added successfully'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product: $e'),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadProgress = '';
        });
      }
    }
  }
}
