#!/bin/bash

# Create a DMG installer for Buen Font Installer
APP_NAME="Buen Font Installer"
VERSION="1.0"
DMG_NAME="${APP_NAME}-v${VERSION}.dmg"
VOLUME_NAME="${APP_NAME}"
BACKGROUND_IMG="dmg-background.png"

echo "Creating DMG installer..."

# Make sure the app is built
if [ ! -d "${APP_NAME}.app" ]; then
    echo "Building app first..."
    ./build-app.sh
fi

# Create a temporary directory for DMG contents
TMP_DIR=$(mktemp -d)
TMP_DMG="tmp-${DMG_NAME}"

cp -R "${APP_NAME}.app" "$TMP_DIR/"
ln -s /Applications "$TMP_DIR/Applications"

# Create temporary DMG
echo "Creating temporary DMG..."
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$TMP_DIR" -ov -format UDRW "$TMP_DMG"

# Mount the DMG
echo "Mounting DMG..."
hdiutil attach -readwrite -noverify -noautoopen "$TMP_DMG"
MOUNT_DIR="/Volumes/$VOLUME_NAME"

echo "Mounted at: $MOUNT_DIR"

# Wait for mount
sleep 3

# Copy background image if it exists
if [ -f "$BACKGROUND_IMG" ]; then
    echo "Adding custom background..."
    mkdir "$MOUNT_DIR/.background"
    cp "$BACKGROUND_IMG" "$MOUNT_DIR/.background/"

    # Set the background and icon positions using AppleScript
    echo '
    tell application "Finder"
        tell disk "'$VOLUME_NAME'"
            open
            set current view of container window to icon view
            set toolbar visible of container window to false
            set statusbar visible of container window to false
            set pathbar visible of container window to false
            set sidebar width of container window to 0
            set the bounds of container window to {400, 100, 828, 482}
            set viewOptions to the icon view options of container window
            set arrangement of viewOptions to not arranged
            set icon size of viewOptions to 80
            set background picture of viewOptions to file ".background:dmg-background.png"
            set text size of viewOptions to 12
            set position of item "'${APP_NAME}'.app" of container window to {304, 165}
            set position of item "Applications" of container window to {124, 165}
            close
            open
            update without registering applications
            delay 2
        end tell
    end tell
    ' | osascript

    # Wait for changes to apply
    sleep 3
fi

# Unmount
echo "Finalizing DMG..."
hdiutil detach "$MOUNT_DIR"

# Convert to compressed read-only
rm -f "${DMG_NAME}"
hdiutil convert "$TMP_DMG" -format UDZO -o "${DMG_NAME}"

# Clean up
rm -f "$TMP_DMG"
rm -rf "$TMP_DIR"

echo "✓ DMG created: ${DMG_NAME}"
echo ""
echo "To distribute:"
echo "1. Upload ${DMG_NAME} to GitHub releases"
echo "2. Share the download link"
echo "3. Users drag the app to Applications folder"

if [ ! -f "$BACKGROUND_IMG" ]; then
    echo ""
    echo "💡 Tip: Create a ${BACKGROUND_IMG} file (600x450px) for a custom DMG background"
fi

