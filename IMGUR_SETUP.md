# Setting Up Imgur API for Recipe Image Uploads

## Overview
ForkCast uses Imgur API to upload and host recipe images. This document explains how to set up the Imgur Client ID for image upload functionality.

## Steps to Get Imgur Client ID

1. **Create an Imgur Account**
   - Go to [https://imgur.com/](https://imgur.com/)
   - Sign up for a free account if you don't have one

2. **Register Your Application**
   - Visit [https://api.imgur.com/oauth2/addclient](https://api.imgur.com/oauth2/addclient)
   - Fill in the application details:
     - **Application name**: ForkCast Recipe Manager
     - **Authorization type**: Select "OAuth 2 authorization without a callback URL"
     - **Email**: Your email address
     - **Description**: Image upload service for ForkCast recipe management
   - Accept the terms and submit

3. **Get Your Client ID**
   - After registration, you'll receive a **Client ID** and **Client Secret**
   - Copy the **Client ID** (you only need this for anonymous uploads)

4. **Add Client ID to the App**
   - Open `lib/services/imgur_service.dart`
   - Find this line:
     ```dart
     static const String _clientId = 'YOUR_IMGUR_CLIENT_ID_HERE';
     ```
   - Replace `YOUR_IMGUR_CLIENT_ID_HERE` with your actual Client ID:
     ```dart
     static const String _clientId = 'your_actual_client_id_12345';
     ```

5. **Save and Test**
   - Save the file
   - Run the app
   - Try uploading an image from the Recipe Management page

## API Limits

**Free Tier Limits:**
- 12,500 uploads per day
- 1,250 uploads per hour
- 50 uploads per minute

These limits are more than sufficient for a recipe management application.

## Troubleshooting

### Error: "Please set your Imgur Client ID"
- Make sure you've replaced `YOUR_IMGUR_CLIENT_ID_HERE` with your actual Client ID
- Restart the app after making changes

### Error: "Imgur upload failed with status 403"
- Your Client ID might be invalid
- Check if you copied the correct Client ID (not the Client Secret)
- Verify your Imgur application is still active

### Error: "Imgur upload failed with status 429"
- You've reached the rate limit
- Wait a few minutes and try again
- Consider upgrading to Imgur Pro if you need higher limits

## Security Notes

- The Client ID is safe to include in client-side code
- For production apps, consider storing the Client ID in environment variables
- Never commit your Client Secret (we don't use it for anonymous uploads)

## Alternative: Using Environment Variables (Recommended for Production)

1. Create a `.env` file in the project root:
   ```
   IMGUR_CLIENT_ID=your_actual_client_id_here
   ```

2. Add to `.gitignore`:
   ```
   .env
   ```

3. Use the `flutter_dotenv` package to load it securely

## Documentation

- Imgur API Documentation: [https://apidocs.imgur.com/](https://apidocs.imgur.com/)
- Image Upload Endpoint: [https://apidocs.imgur.com/#de179b6a-3eda-4406-a8d7-1fb06c17cb9c](https://apidocs.imgur.com/#de179b6a-3eda-4406-a8d7-1fb06c17cb9c)
