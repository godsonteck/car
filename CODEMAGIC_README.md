# Codemagic CI/CD Setup Guide

This guide explains how to configure Codemagic for building and deploying your Flutter car rental app.

## Prerequisites

1. **Codemagic Account**: Sign up at [codemagic.io](https://codemagic.io)
2. **App Store Connect API Key** (for iOS):
   - Go to App Store Connect → Users and Access → Keys
   - Generate a new API Key with App Manager access
   - Download the `.p8` file
3. **Google Play Service Account** (for Android):
   - Go to Google Cloud Console
   - Create a service account with Google Play Android Developer API access
   - Download the JSON key file
4. **Code Signing Certificates**:
   - iOS: Distribution certificate and provisioning profile
   - Android: Upload keystore file

## Environment Variables Setup

### Required Environment Variables

Add these to your Codemagic project settings:

#### iOS Variables
```
APP_STORE_CONNECT_PRIVATE_KEY=<content of .p8 file>
APP_STORE_CONNECT_KEY_IDENTIFIER=<key ID from App Store Connect>
APP_STORE_CONNECT_ISSUER_ID=<issuer ID from App Store Connect>
CM_CERTIFICATE=<base64 encoded .p12 certificate>
CM_CERTIFICATE_PASSWORD=<certificate password>
CM_PROVISIONING_PROFILE=<base64 encoded provisioning profile>
```

#### Android Variables
```
GCLOUD_SERVICE_ACCOUNT_CREDENTIALS=<content of service account JSON>
```

#### Firebase (Optional)
```
FIREBASE_TOKEN=<firebase CI token>
```

## Workflow Configuration

The `codemagic.yaml` file includes three workflows:

### 1. `ios-workflow`
- Builds iOS app only
- Generates `.app` and `.dSYM` artifacts
- Can submit to TestFlight (set `submit_to_app_store: true`)

### 2. `android-workflow`
- Builds Android APK and AAB
- Publishes to Google Play internal track
- Configurable rollout fraction

### 3. `build-and-deploy`
- Builds both iOS and Android
- Creates all artifacts
- Deploys to both stores

## Firebase Configuration

### For iOS
1. Download `GoogleService-Info.plist` from Firebase Console
2. The file is already configured in the project
3. **Important**: Add `GoogleService-Info.plist` to `.gitignore` (already done)

### For Android
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`
3. **Important**: Add to `.gitignore` (already done)

## Code Signing Setup

### iOS Code Signing
1. In Codemagic, go to your app settings
2. Upload your iOS distribution certificate (`.p12`)
3. Upload your provisioning profile
4. The environment variables will be automatically populated

### Android Code Signing
1. Generate a keystore:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Upload the keystore file to Codemagic
3. Set these environment variables:
   ```
   CM_KEYSTORE=<base64 encoded keystore>
   CM_KEYSTORE_PASSWORD=<keystore password>
   CM_KEY_ALIAS=<key alias>
   CM_KEY_PASSWORD=<key password>
   ```

## Building and Testing

### Manual Build Triggers
- Push to `master` branch (triggers `build-and-deploy`)
- Push to `develop` branch (triggers individual platform builds)
- Create a tag (triggers release builds)

### Build Artifacts
After successful builds, download:
- iOS: `Runner.app` and `Runner.app.dSYM.zip`
- Android: `app-release.apk` and `app-release.aab`

## Troubleshooting

### Common Issues

1. **Pod Install Fails**
   - Ensure Podfile is correct
   - Check Ruby version compatibility
   - Verify CocoaPods version

2. **Firebase Configuration**
   - Ensure `GoogleService-Info.plist` is in the correct location
   - Verify bundle ID matches Firebase project
   - Check API keys are properly configured

3. **Code Signing Issues**
   - Verify certificates are not expired
   - Ensure provisioning profile matches bundle ID
   - Check team ID in App Store Connect

4. **Build Timeouts**
   - Increase `max_build_duration` in workflow
   - Optimize Flutter build process
   - Use build caching effectively

### Debug Tips

1. **Check Build Logs**: Codemagic provides detailed logs for each step
2. **Test Locally**: Run builds locally before pushing to CI
3. **Environment Variables**: Double-check all required variables are set
4. **Dependencies**: Ensure all Flutter packages are compatible

## Deployment Strategy

### Development
- Use `internal` track for Android
- Use TestFlight for iOS
- Automatic builds on push to `develop` branch

### Production
- Use `production` track for Android
- Submit to App Store review for iOS
- Tag-based releases trigger production builds

## Security Notes

- Never commit sensitive files (certificates, API keys)
- Use Codemagic's encrypted environment variables
- Rotate certificates regularly
- Monitor API key usage in Firebase/Google Cloud

## Support

For Codemagic-specific issues:
- Check Codemagic documentation
- Review build logs for error messages
- Contact Codemagic support

For Flutter-specific issues:
- Verify local builds work
- Check Flutter version compatibility
- Test on multiple devices/simulators
