#!/bin/bash
# Strip extended attributes from Flutter framework before building

TARGET_FRAMEWORK="$BUILD_DIR/../Debug-$PLATFORM_NAME/Flutter.framework/Flutter"

if [ -f "$TARGET_FRAMEWORK" ]; then
    echo "Found Flutter framework at: $TARGET_FRAMEWORK"
    xattr -c "$TARGET_FRAMEWORK"
    echo "Stripped extended attributes from Flutter binary"
fi

# Also strip from the app frameworks
find "$BUILT_PRODUCTS_DIR" -name "*.framework" -type d 2>/dev/null | while read framework; do
    find "$framework" -type f -not -path "*/_CodeSignature/*" -print0 2>/dev/null | xargs -0 xattr -c 2>/dev/null || true
done
