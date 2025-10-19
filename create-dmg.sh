#!/bin/bash

# Create a DMG installer for Buen Font Installer
set -e

APP_NAME="Buen Font Installer"
BACKGROUND_IMG="dmg-background.png"
SIGNING_IDENTITY="${DEVELOPER_ID_CERTIFICATE:-}"
APPLE_ID="${APPLE_ID:-}"
KEYCHAIN_PROFILE="${NOTARIZATION_KEYCHAIN_PROFILE:-notarytool-password}"

echo "Creating DMG installer..."

# Make sure the app is built
if [ ! -d "${APP_NAME}.app" ]; then
    echo "Building app first..."
    ./build-app.sh
fi

# Read version from Info.plist
VERSION=$(defaults read "$(pwd)/${APP_NAME}.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "1.0")
DMG_NAME="${APP_NAME}-v${VERSION}.dmg"
VOLUME_NAME="${APP_NAME}"

echo "Version: $VERSION"

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

# Clean up temporary files
rm -f "$TMP_DMG"
rm -rf "$TMP_DIR"

echo "✓ DMG created: ${DMG_NAME}"

# Sign the DMG if we have a signing identity
if [ -n "$SIGNING_IDENTITY" ] && [ "$SIGNING_IDENTITY" != "-" ]; then
    echo ""
    echo "🔐 Signing DMG..."
    codesign --sign "$SIGNING_IDENTITY" --timestamp "${DMG_NAME}"

    if [ $? -eq 0 ]; then
        echo "✓ DMG signed successfully"

        # Notarize the DMG if Apple ID is provided
        if [ -n "$APPLE_ID" ]; then
            echo ""
            echo "📤 Submitting DMG for notarization..."
            echo ""

            # Submit WITHOUT --wait to avoid hanging
            SUBMIT_OUTPUT=$(xcrun notarytool submit "${DMG_NAME}" \
                --keychain-profile "$KEYCHAIN_PROFILE" \
                2>&1)

            SUBMIT_EXIT=$?

            if [ $SUBMIT_EXIT -eq 0 ]; then
                # Extract submission ID
                SUBMISSION_ID=$(echo "$SUBMIT_OUTPUT" | grep -o 'id: [a-f0-9-]*' | head -1 | cut -d' ' -f2)

                echo "✓ DMG submitted for notarization"
                echo "  Submission ID: $SUBMISSION_ID"
                echo ""
                echo "⏳ Waiting for Apple to process (usually 5-30 minutes)..."
                echo "   Will check status for up to 15 minutes..."
                echo ""

                # Poll for status with timeout (15 minutes = 900 seconds)
                MAX_WAIT=900
                WAIT_INTERVAL=30
                ELAPSED=0

                while [ $ELAPSED -lt $MAX_WAIT ]; do
                    sleep $WAIT_INTERVAL
                    ELAPSED=$((ELAPSED + WAIT_INTERVAL))

                    # Check status
                    STATUS_OUTPUT=$(xcrun notarytool info "$SUBMISSION_ID" \
                        --keychain-profile "$KEYCHAIN_PROFILE" 2>&1)

                    STATUS=$(echo "$STATUS_OUTPUT" | grep "status:" | awk '{print $2}')

                    if [ "$STATUS" = "Accepted" ]; then
                        echo "✓ Notarization successful! (${ELAPSED}s)"
                        echo ""

                        # Staple the ticket
                        echo "📎 Stapling notarization ticket..."
                        xcrun stapler staple "${DMG_NAME}"

                        if [ $? -eq 0 ]; then
                            echo "✓ DMG is fully notarized and stapled!"
                            echo ""
                            echo "🎉 Distribution-ready DMG created!"
                        fi
                        break
                    elif [ "$STATUS" = "Invalid" ] || [ "$STATUS" = "Rejected" ]; then
                        echo "❌ Notarization failed with status: $STATUS"
                        echo ""
                        echo "Get logs with:"
                        echo "  xcrun notarytool log $SUBMISSION_ID --keychain-profile $KEYCHAIN_PROFILE"
                        break
                    else
                        # Still in progress
                        printf "."
                    fi
                done

                if [ $ELAPSED -ge $MAX_WAIT ]; then
                    echo ""
                    echo ""
                    echo "⏱️  Notarization still in progress after 15 minutes"
                    echo ""
                    echo "The DMG is signed and uploaded. Apple's servers may be slow."
                    echo "Check status later with:"
                    echo "  xcrun notarytool info $SUBMISSION_ID --keychain-profile $KEYCHAIN_PROFILE"
                    echo ""
                    echo "Once accepted, staple the ticket with:"
                    echo "  xcrun stapler staple \"${DMG_NAME}\""
                fi
            else
                echo "❌ Failed to submit for notarization"
                echo "$SUBMIT_OUTPUT"
            fi
        fi
    fi
fi

echo ""
echo "To distribute:"
echo "1. Upload ${DMG_NAME} to GitHub releases"
echo "2. Update appcast.xml with new version info"
echo "3. Share the download link"

if [ ! -f "$BACKGROUND_IMG" ]; then
    echo ""
    echo "💡 Tip: Create a ${BACKGROUND_IMG} file (600x450px) for a custom DMG background"
fi

