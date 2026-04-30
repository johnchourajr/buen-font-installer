#!/bin/bash

# Build app for Mac App Store distribution
set -e

echo "🍎 Building for Mac App Store..."
echo "================================"
echo ""

# Note: do not `source .env.secrets` here. Keep build scripts deterministic and
# avoid executing arbitrary shell in a secrets file.

# Check for Mac App Store certificate
MAC_APP_STORE_CERT=$(security find-identity -v -p codesigning | grep "3rd Party Mac Developer Application" | head -1 | grep -o '"[^"]*"' | tr -d '"')

if [ -z "$MAC_APP_STORE_CERT" ]; then
    echo "❌ No Mac App Store certificate found!"
    echo ""
    echo "To fix this:"
    echo "1. Go to https://developer.apple.com/account/resources/certificates"
    echo "2. Create a 'Mac App Store' certificate"
    echo "3. Install it in your keychain"
    echo ""
    exit 1
fi

echo "✓ Found Mac App Store certificate: $MAC_APP_STORE_CERT"
echo ""

# Set signing identity
export SIGNING_IDENTITY="$MAC_APP_STORE_CERT"

# Build the app (reuse existing build script)
echo "📦 Building app..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Create app bundle structure
APP_NAME="Buen Font Installer.app"
APP_DIR="$APP_NAME/Contents"
SPARKLE_FRAMEWORK=".build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework"
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" Info.plist 2>/dev/null || echo "dev.muybuen.buen-font-installer")

find_provisioning_profile() {
    local bundle_id="$1"
    local profiles_dir="$HOME/Library/MobileDevice/Provisioning Profiles"

    if [ ! -d "$profiles_dir" ]; then
        return 1
    fi

    local best_profile=""
    local best_mtime=0

    while IFS= read -r -d '' profile; do
        local decoded
        decoded="$(security cms -D -i "$profile" 2>/dev/null || true)"
        if [ -z "$decoded" ]; then
            continue
        fi

        if ! echo "$decoded" | grep -q "$bundle_id"; then
            continue
        fi

        local mtime
        mtime=$(stat -f "%m" "$profile" 2>/dev/null || echo 0)
        if [ "$mtime" -gt "$best_mtime" ]; then
            best_mtime="$mtime"
            best_profile="$profile"
        fi
    done < <(find "$profiles_dir" -name "*.provisionprofile" -print0)

    if [ -n "$best_profile" ]; then
        echo "$best_profile"
        return 0
    fi

    return 1
}

# Create app bundle structure
rm -rf "$APP_NAME"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"
mkdir -p "$APP_DIR/Frameworks"

# Copy executable
cp .build/release/BuenFontInstaller "$APP_DIR/MacOS/"

# Set rpath for Sparkle framework
echo "🔗 Setting rpath for Sparkle..."
install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP_DIR/MacOS/BuenFontInstaller" 2>/dev/null || true

# Copy Info.plist
cp Info.plist "$APP_DIR/"

# Embed provisioning profile (required for TestFlight eligibility)
echo "🪪 Embedding provisioning profile (for TestFlight)..."
PROFILE_PATH="$(find_provisioning_profile "$BUNDLE_ID" || true)"
if [ -n "$PROFILE_PATH" ]; then
    cp "$PROFILE_PATH" "$APP_DIR/embedded.provisionprofile"
    echo "✓ Embedded: $(basename "$PROFILE_PATH")"
else
    echo "⚠ No matching provisioning profile found in:"
    echo "  $HOME/Library/MobileDevice/Provisioning Profiles"
    echo "  Open Xcode → Settings → Accounts → Download Manual Profiles"
    echo "  Then re-run this script."
fi

# Copy icon assets
cp -r Sources/Resources/Assets.xcassets "$APP_DIR/Resources/"

# Create icns file from the iconset
mkdir -p /tmp/AppIcon.iconset
cp Sources/Resources/Assets.xcassets/AppIcon.appiconset/*.png /tmp/AppIcon.iconset/ 2>/dev/null
iconutil -c icns /tmp/AppIcon.iconset -o "$APP_DIR/Resources/AppIcon.icns" 2>/dev/null
rm -rf /tmp/AppIcon.iconset

# Copy Sparkle framework if it exists
if [ -d "$SPARKLE_FRAMEWORK" ]; then
    echo "📦 Embedding Sparkle framework..."
    cp -R "$SPARKLE_FRAMEWORK" "$APP_DIR/Frameworks/"

    # Remove extended attributes
    echo "🧹 Cleaning extended attributes..."
    xattr -cr "$APP_DIR/Frameworks/Sparkle.framework"

    # Sign the framework
    echo "🔐 Signing Sparkle framework..."
    codesign --force --sign "$SIGNING_IDENTITY" \
        --timestamp \
        --options runtime \
        "$APP_DIR/Frameworks/Sparkle.framework/Versions/B/Autoupdate" 2>/dev/null
    codesign --force --sign "$SIGNING_IDENTITY" \
        --timestamp \
        --options runtime \
        "$APP_DIR/Frameworks/Sparkle.framework/Versions/B/Updater.app" 2>/dev/null
    codesign --force --sign "$SIGNING_IDENTITY" \
        --timestamp \
        --options runtime \
        "$APP_DIR/Frameworks/Sparkle.framework" 2>/dev/null
fi

# Code sign the main executable
echo "🔐 Signing app executable..."
codesign --force --sign "$SIGNING_IDENTITY" \
    --timestamp \
    --options runtime \
    --entitlements BuenFontInstaller.entitlements \
    "$APP_DIR/MacOS/BuenFontInstaller"

# Code sign the entire app bundle
echo "🔐 Signing app bundle..."
codesign --force --deep --sign "$SIGNING_IDENTITY" \
    --timestamp \
    --options runtime \
    --entitlements BuenFontInstaller.entitlements \
    "$APP_NAME"

if [ $? -eq 0 ]; then
    echo "✓ App signed successfully for Mac App Store"

    # Verify the signature
    codesign --verify --verbose "$APP_NAME"
else
    echo "❌ Code signing failed"
    exit 1
fi

echo ""
echo "✓ App bundle created: $APP_NAME"
echo ""

# Create installer package
echo "📦 Creating installer package..."
PKG_NAME="Buen Font Installer.pkg"

# Find installer certificate (installer certs don't have codesigning capability)
INSTALLER_CERT=$(security find-identity -v | grep "3rd Party Mac Developer Installer" | head -1 | grep -o '"[^"]*"' | tr -d '"')

if [ -z "$INSTALLER_CERT" ]; then
    echo "❌ No Mac App Store Installer certificate found!"
    echo ""
    echo "To fix this:"
    echo "1. Go to https://developer.apple.com/account/resources/certificates"
    echo "2. Create a 'Mac App Store Installer' certificate"
    echo "3. Install it in your keychain"
    echo ""
    exit 1
fi

echo "✓ Found installer certificate: $INSTALLER_CERT"

# Create package
productbuild --component "$APP_NAME" /Applications \
    --sign "$INSTALLER_CERT" \
    "$PKG_NAME"

if [ $? -eq 0 ]; then
    echo "✓ Package created: $PKG_NAME"
    echo ""
    echo "Next steps:"
    echo "1. Upload to TestFlight using Transporter app:"
    echo "   - Download Transporter from Mac App Store"
    echo "   - Drag $PKG_NAME into Transporter"
    echo "   - Click 'Deliver'"
    echo ""
    echo "2. Or upload via command line:"
    echo "   xcrun altool --upload-package \"$PKG_NAME\" \\"
    echo "     --type macos \\"
    echo "     --username \"your@email.com\" \\"
    echo "     --password \"app-specific-password\" \\"
    echo "     --bundle-id \"dev.muybuen.buen-font-installer\""
else
    echo "❌ Package creation failed"
    exit 1
fi
