import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Service for uploading images to Cloudinary using unsigned upload preset
/// API Documentation: https://cloudinary.com/documentation/image_upload_api_reference
class CloudinaryService {
  // Cloudinary Configuration (Unsigned Upload)
  static const String _cloudName = 'du6eemdlu';
  static const String _uploadPreset = 'meal_app_upload'; // Unsigned upload preset
  static const String _uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';
  
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Pick an image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  /// Upload image to Cloudinary using unsigned upload preset
  /// Returns the secure URL to the uploaded image
  Future<String?> uploadImage(File imageFile, {String? title, String? description}) async {
    try {
      // Validate cloud name
      if (_cloudName == 'YOUR_CLOUD_NAME') {
        throw Exception(
          'Please set your Cloudinary Cloud Name in cloudinary_service.dart\n'
          'Find it in your Cloudinary Console Dashboard'
        );
      }

      // Prepare multipart request for unsigned upload
      final uri = Uri.parse(_uploadUrl);
      final request = http.MultipartRequest('POST', uri);
      
      // Add upload preset (required for unsigned upload)
      request.fields['upload_preset'] = _uploadPreset;
      
      // Add optional context metadata
      if (title != null && description != null) {
        request.fields['context'] = 'alt=$title|caption=$description';
      } else if (title != null) {
        request.fields['context'] = 'alt=$title';
      } else if (description != null) {
        request.fields['context'] = 'caption=$description';
      }
      
      // Add image file
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      // Send request
      print('Uploading image to Cloudinary (unsigned)...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Parse response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final imageUrl = jsonResponse['secure_url'];
        print('Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        print('Cloudinary upload failed with status ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  /// Delete an image from Cloudinary
  /// Note: Deletion with unsigned upload presets is not supported.
  /// For deletion, you would need to use authenticated API calls with your API secret.
  /// This is a placeholder method for future implementation if needed.
  Future<bool> deleteImage(String publicId) async {
    print('Image deletion with unsigned upload preset is not supported.');
    print('Public ID: $publicId');
    print('To enable deletion, implement server-side deletion using Cloudinary Admin API.');
    return false;
  }

  /// Show image source selection dialog
  Future<File?> showImageSourceDialog(context) async {
    return await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await pickImageFromGallery();
                  if (context.mounted) {
                    Navigator.pop(context, file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await pickImageFromCamera();
                  if (context.mounted) {
                    Navigator.pop(context, file);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
