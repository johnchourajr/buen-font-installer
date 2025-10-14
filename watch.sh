#!/bin/bash

echo "👀 Watching for changes... Press Ctrl+C to stop"
echo "Will auto-rebuild and relaunch when Swift files change"
echo ""

# Kill any existing instance
killall BuenFontInstaller 2>/dev/null

# Function to build and run
build_and_run() {
    echo "🔨 Building..."
    swift build -c debug

    if [ $? -eq 0 ]; then
        echo "✅ Build successful"

        # Kill previous instance
        killall BuenFontInstaller 2>/dev/null

        # Run the app
        .build/debug/BuenFontInstaller &
        echo "🚀 App launched"
    else
        echo "❌ Build failed"
    fi
}

# Initial build and run
build_and_run

# Watch for changes using fswatch (install with: brew install fswatch)
if command -v fswatch &> /dev/null; then
    fswatch -o Sources/ | while read; do
        echo ""
        echo "📝 Changes detected..."
        build_and_run
    done
else
    echo ""
    echo "⚠️  fswatch not installed. Install it with: brew install fswatch"
    echo "For now, watching manually with a loop..."

    # Fallback: Check for changes every 2 seconds
    last_mod=$(find Sources -type f -name "*.swift" -exec stat -f "%m" {} \; | sort -n | tail -1)

    while true; do
        sleep 2
        current_mod=$(find Sources -type f -name "*.swift" -exec stat -f "%m" {} \; | sort -n | tail -1)

        if [ "$current_mod" != "$last_mod" ]; then
            echo ""
            echo "📝 Changes detected..."
            build_and_run
            last_mod=$current_mod
        fi
    done
fi

