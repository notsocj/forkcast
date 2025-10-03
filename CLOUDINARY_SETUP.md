# Cloudinary Image Upload Setup Guide

## Overview
ForkCast uses **Cloudinary** for image hosting and management, specifically for recipe images uploaded through the admin content management interface.

## Configuration

### Cloudinary Account
- **Cloud Name**: `du6eemdlu`
- **Upload Preset**: `meal_app_upload` (unsigned)
- **API Documentation**: https://cloudinary.com/documentation/image_upload_api_reference

### Upload Method
We use **unsigned upload presets** for client-side uploads without exposing API secrets. This is the recommended approach for mobile applications.

## Implementation Details

### Service Location
- **File**: `lib/services/cloudinary_service.dart`
- **Class**: `CloudinaryService`

### Key Features
1. **Image Picker Integration**
   - Pick from gallery: `pickImageFromGallery()`
   - Take photo: `pickImageFromCamera()`

2. **Unsigned Upload**
   - No API secret required in client code
   - Uses upload preset for authentication
   - Returns secure HTTPS URL

3. **Image Upload**
   - Method: `uploadImage(File imageFile, {String? title, String? description})`
   - Returns: `Future<String?>` (URL of uploaded image)
   - Upload endpoint: `https://api.cloudinary.com/v1_1/du6eemdlu/image/upload`

### Usage Example

```dart
final cloudinaryService = CloudinaryService();

// Pick image from gallery
final imageFile = await cloudinaryService.pickImageFromGallery();

if (imageFile != null) {
  // Upload to Cloudinary
  final imageUrl = await cloudinaryService.uploadImage(
    imageFile,
    title: 'Recipe Name',
    description: 'Recipe description',
  );
  
  if (imageUrl != null) {
    print('Image uploaded: $imageUrl');
    // Save imageUrl to Firebase
  }
}
```

## Integration Points

### Admin Recipe Management
- **File**: `lib/features/admin/content_management/manage_recipes_page.dart`
- **Flow**:
  1. Admin adds/edits recipe
  2. Selects image via CloudinaryService
  3. Image uploads to Cloudinary on save
  4. Cloudinary URL saved to Firebase recipe document

### Recipe Display
- **File**: `lib/features/meal_planning/recipe_detail_page.dart`
- **Display**: Automatically handles both network URLs (Cloudinary) and local assets

## Upload Preset Configuration

The upload preset `meal_app_upload` should be configured in your Cloudinary dashboard:

1. Go to Settings → Upload → Upload presets
2. Click on `meal_app_upload`
3. Ensure:
   - **Signing Mode**: Unsigned
   - **Folder**: (optional) Set to `recipes/` or similar
   - **Access Mode**: Public
   - **Unique Filename**: Enabled (recommended)
   - **Overwrite**: Disabled (recommended)

## Image Deletion

**Note**: Image deletion is NOT supported with unsigned upload presets for security reasons.

If deletion is needed:
1. Implement server-side deletion using Cloudinary Admin API
2. Use authenticated API calls with API secret (server-side only)
3. Alternative: Set expiration policies in Cloudinary settings

Current implementation of `deleteImage()` is a placeholder and returns false.

## Security Considerations

✅ **Good Practices**:
- Using unsigned upload preset (no API secret in client)
- Client-side uploads without exposing credentials
- Secure HTTPS URLs for all uploaded images

❌ **Do NOT**:
- Include API secret in client code
- Use signed uploads from mobile app
- Expose admin API credentials

## Troubleshooting

### Common Issues

**1. "Invalid Signature" Error**
- **Cause**: Trying to use signed upload with wrong signature
- **Fix**: Ensure using unsigned upload (no signature, timestamp, or API key in request)

**2. "Upload preset not found" Error**
- **Cause**: Upload preset name mismatch or not created
- **Fix**: Verify `meal_app_upload` exists in Cloudinary dashboard

**3. "401 Unauthorized" Error**
- **Cause**: Upload preset is configured as signed instead of unsigned
- **Fix**: Change upload preset to unsigned mode in Cloudinary dashboard

**4. Image URL not saving**
- **Cause**: Network error or Firebase write failure
- **Fix**: Check console logs for error messages

## Testing

### Test Image Upload
1. Open app in debug mode
2. Navigate to Admin → Manage Recipes
3. Click "Add Recipe" or edit existing recipe
4. Click image placeholder → Choose from Gallery/Take Photo
5. Fill required fields and save
6. Check console for upload status:
   ```
   I/flutter: Uploading image to Cloudinary (unsigned)...
   I/flutter: Image uploaded successfully: https://res.cloudinary.com/...
   ```

### Verify Upload
- Check Cloudinary dashboard → Media Library
- Images should appear in the specified folder
- URL format: `https://res.cloudinary.com/du6eemdlu/image/upload/v<timestamp>/<public_id>.jpg`

## Migration from Imgur

The previous implementation used Imgur API, which was replaced due to:
- Imgur API access limitations
- Better features in Cloudinary (transformations, optimizations)
- More reliable upload for production apps

**Changed Files**:
- `lib/services/imgur_service.dart` → `lib/services/cloudinary_service.dart`
- `lib/features/admin/content_management/manage_recipes_page.dart` (imports updated)

## Resources

- [Cloudinary Upload API](https://cloudinary.com/documentation/image_upload_api_reference)
- [Unsigned Upload Presets](https://cloudinary.com/documentation/upload_presets)
- [Flutter Image Picker](https://pub.dev/packages/image_picker)
- [HTTP Package](https://pub.dev/packages/http)

## Support

For issues or questions:
1. Check Cloudinary dashboard for upload logs
2. Review Flutter console logs for detailed error messages
3. Verify upload preset configuration
4. Test with sample images first
