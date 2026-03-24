#!/bin/bash
set -e

echo "🍎 Building for Mac App Store..."
echo ""

# Check for Mac App Store application certificate
APP_CERT=$(security find-identity -v -p codesigning | grep -E "Apple Distribution|3rd Party Mac Developer Application" | head -1 | grep -o '"[^"]*"' | tr -d '"')
if [ -z "$APP_CERT" ]; then
    echo "❌ No '3rd Party Mac Developer Application' certificate found"
    echo ""
    echo "To fix:"
    echo "  1. Open Xcode → Settings → Accounts → Manage Certificates"
    echo "  2. Click + → Mac App Store Application"
    echo "  Or create one at: https://developer.apple.com/account/resources/certificates"
    exit 1
fi
echo "✓ App certificate: $APP_CERT"

# Check for Mac App Store installer certificate (needed for .pkg)
PKG_CERT=$(security find-identity -v | grep -E "Mac Installer Distribution|3rd Party Mac Developer Installer" | head -1 | grep -o '"[^"]*"' | tr -d '"')
if [ -z "$PKG_CERT" ]; then
    echo "⚠ No '3rd Party Mac Developer Installer' certificate found — .pkg step will be skipped"
else
    echo "✓ Installer certificate: $PKG_CERT"
fi

# Build
echo ""
echo "🔨 Building (release)..."
swift build -c release

# Variables
APP_NAME="Buen Font Installer.app"
APP_DIR="$APP_NAME/Contents"
PKG_NAME="Buen Font Installer.pkg"

# Assemble app bundle
echo ""
echo "📦 Assembling app bundle..."
rm -rf "$APP_NAME"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

cp .build/release/BuenFontInstaller "$APP_DIR/MacOS/"
cp Info.plist "$APP_DIR/"

# Compile asset catalog (required by App Store — produces Assets.car)
echo "🎨 Compiling asset catalog..."
actool \
    --compile "$APP_DIR/Resources" \
    --app-icon AppIcon \
    --output-partial-info-plist /tmp/assetcatalog_info.plist \
    --platform macosx \
    --minimum-deployment-target 14.0 \
    --target-device mac \
    Sources/Resources/Assets.xcassets 2>/dev/null || true

# Build icon
echo "🎨 Building icon..."
mkdir -p /tmp/AppIcon.iconset
for size in 16 32 128 256 512; do
    cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/icon_${size}x${size}.png" \
       "/tmp/AppIcon.iconset/icon_${size}x${size}.png" 2>/dev/null || true
    cp "Sources/Resources/Assets.xcassets/AppIcon.appiconset/icon_${size}x${size}@2x.png" \
       "/tmp/AppIcon.iconset/icon_${size}x${size}@2x.png" 2>/dev/null || true
done
iconutil -c icns /tmp/AppIcon.iconset -o "$APP_DIR/Resources/AppIcon.icns"
rm -rf /tmp/AppIcon.iconset

# Sign app bundle
# Note: --options runtime is for Developer ID/notarization — not used for App Store
echo ""
echo "🔐 Signing app bundle..."
codesign --force --deep --sign "$APP_CERT" \
    --timestamp \
    --entitlements BuenFontInstaller.entitlements \
    "$APP_NAME"

codesign --verify --verbose "$APP_NAME"
echo "✓ App signed"

# Create .pkg for App Store submission
if [ -n "$PKG_CERT" ]; then
    echo ""
    echo "📦 Creating installer package..."
    rm -f "$PKG_NAME"
    productbuild \
        --component "$APP_NAME" /Applications \
        --sign "$PKG_CERT" \
        "$PKG_NAME"
    echo "✓ Package created: $PKG_NAME"
    echo ""
    echo "Upload with asc:"
    echo "  asc builds upload --app YOUR_APP_ID --pkg \"$PKG_NAME\""
else
    echo ""
    echo "⚠ Skipping .pkg — add a '3rd Party Mac Developer Installer' certificate to enable"
    echo "  Then: asc builds upload --app YOUR_APP_ID --pkg \"$PKG_NAME\""
fi
