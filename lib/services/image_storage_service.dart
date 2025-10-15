import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Service for managing image uploads to Firebase Storage
class ImageStorageService {
  static final ImageStorageService _instance = ImageStorageService._internal();
  factory ImageStorageService() => _instance;
  ImageStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Pick multiple images from gallery
  Future<List<XFile>?> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80, // Compress images
      );
      return images.isNotEmpty ? images : null;
    } catch (e) {
      print('Error picking images: $e');
      return null;
    }
  }

  /// Pick a single image from gallery
  Future<XFile?> pickSingleImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Upload a single image to Firebase Storage
  /// Returns the download URL
  Future<String?> uploadImage(XFile imageFile, String productId) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final Reference ref = _storage.ref().child(
        'products/$productId/$fileName',
      );

      final File file = File(imageFile.path);
      final UploadTask uploadTask = ref.putFile(file);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload multiple images to Firebase Storage
  /// Returns list of download URLs
  Future<List<String>> uploadMultipleImages(
    List<XFile> imageFiles,
    String productId,
  ) async {
    final List<String> downloadUrls = [];

    for (final imageFile in imageFiles) {
      final String? url = await uploadImage(imageFile, productId);
      if (url != null) {
        downloadUrls.add(url);
      }
    }

    return downloadUrls;
  }

  /// Delete an image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Delete all images for a product
  Future<bool> deleteProductImages(String productId) async {
    try {
      final Reference ref = _storage.ref().child('products/$productId');
      final ListResult result = await ref.listAll();

      for (final Reference fileRef in result.items) {
        await fileRef.delete();
      }

      return true;
    } catch (e) {
      print('Error deleting product images: $e');
      return false;
    }
  }
}
