#!/bin/bash

# Notarize the app with Apple
# Requires: Apple Developer account, app-specific password stored in keychain

set -e

APP_NAME="Buen Font Installer.app"
APP_BUNDLE_ID="dev.muybuen.buen-font-installer"
APPLE_ID="${APPLE_ID:-}"
TEAM_ID="${APPLE_TEAM_ID:-}"
KEYCHAIN_PROFILE="${NOTARIZATION_KEYCHAIN_PROFILE:-notarytool-password}"

echo "🍎 Notarizing Buen Font Installer with Apple..."
echo ""

# Check required environment variables
if [ -z "$APPLE_ID" ]; then
    echo "❌ Error: APPLE_ID environment variable not set"
    echo "   Example: export APPLE_ID='your@email.com'"
    exit 1
fi

if [ -z "$TEAM_ID" ]; then
    echo "❌ Error: APPLE_TEAM_ID environment variable not set"
    echo "   Find your Team ID at: https://developer.apple.com/account"
    echo "   Example: export APPLE_TEAM_ID='ABC123XYZ'"
    exit 1
fi

if [ ! -d "$APP_NAME" ]; then
    echo "❌ Error: $APP_NAME not found"
    echo "   Run ./build-app.sh first"
    exit 1
fi

# Check if app is properly signed
echo "🔍 Verifying code signature..."
codesign --verify --verbose "$APP_NAME"
if [ $? -ne 0 ]; then
    echo "❌ Error: App is not properly signed"
    echo "   Make sure DEVELOPER_ID_CERTIFICATE is set when running build-app.sh"
    exit 1
fi

# Create a temporary zip for notarization
echo "📦 Creating archive for notarization..."
ZIP_FILE="BuenFontInstaller-notarization.zip"
rm -f "$ZIP_FILE"
ditto -c -k --keepParent "$APP_NAME" "$ZIP_FILE"

echo "✓ Created $ZIP_FILE"
echo ""

# Submit for notarization
echo "📤 Submitting to Apple for notarization..."
echo "   This may take a few minutes..."
echo ""

# Store the app-specific password in keychain (first time only):
# xcrun notarytool store-credentials "$KEYCHAIN_PROFILE" \
#   --apple-id "$APPLE_ID" \
#   --team-id "$TEAM_ID" \
#   --password "xxxx-xxxx-xxxx-xxxx"

xcrun notarytool submit "$ZIP_FILE" \
    --keychain-profile "$KEYCHAIN_PROFILE" \
    --wait

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Notarization successful!"
    echo ""

    # Staple the notarization ticket to the app
    echo "📎 Stapling notarization ticket to app..."
    xcrun stapler staple "$APP_NAME"

    if [ $? -eq 0 ]; then
        echo "✓ Stapling successful!"
        echo ""
        echo "🎉 App is now notarized and ready for distribution!"
        echo ""
        echo "Next steps:"
        echo "  • Run ./create-dmg.sh to create distribution DMG"
        echo "  • The DMG will also need to be notarized and stapled"
    else
        echo "⚠ Warning: Stapling failed, but notarization succeeded"
        echo "   The app will still work but may show warnings on first launch"
    fi
else
    echo ""
    echo "❌ Notarization failed!"
    echo ""
    echo "To debug, check the log with:"
    echo "  xcrun notarytool log <submission-id> --keychain-profile $KEYCHAIN_PROFILE"
fi

# Clean up
rm -f "$ZIP_FILE"

echo ""
echo "Done!"

