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
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" Info.plist 2>/dev/null || echo "dev.muybuen.buen-font-installer")

find_provisioning_profile() {
    local bundle_id="$1"
    local profiles_dir="$HOME/Library/MobileDevice/Provisioning Profiles"

    if [ ! -d "$profiles_dir" ]; then
        return 1
    fi

    # Pick the newest profile whose entitlements match our bundle id and includes a team identifier.
    # This is a best-effort heuristic that works well when Xcode has already downloaded profiles.
    local best_profile=""
    local best_mtime=0

    while IFS= read -r -d '' profile; do
        local decoded
        decoded="$(security cms -D -i "$profile" 2>/dev/null || true)"
        if [ -z "$decoded" ]; then
            continue
        fi

        # Match either application-identifier (TEAMID.bundle) or the explicit bundle-id in Entitlements.
        if ! echo "$decoded" | grep -q "$bundle_id"; then
            continue
        fi

        # Prefer profiles that look like Mac App Store / sandboxed distribution profiles (not developer-id).
        if ! echo "$decoded" | grep -q "ProvisionedDevices"; then
            # ProvisionedDevices is usually absent for App Store distribution, so this is OK.
            :
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

# Assemble app bundle
echo ""
echo "📦 Assembling app bundle..."
rm -rf "$APP_NAME"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

cp .build/release/BuenFontInstaller "$APP_DIR/MacOS/"
cp Info.plist "$APP_DIR/"

# Embed provisioning profile (required for TestFlight eligibility)
echo ""
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
