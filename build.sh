#!/bin/bash
# 编译脚本 - WatchPairFix
# 输出: watchpair-fix/build/WatchPairFix.ipa

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="WatchPairFix"

echo "📱 编译 $APP_NAME..."

# 创建 Swift 项目结构
mkdir -p "$BUILD_DIR/Sources"

# 复制源码
cp "$PROJECT_DIR/WatchPairFixApp.swift" "$BUILD_DIR/Sources/main.swift"

# 编译
swiftc \
  -sdk $(xcrun --sdk iphoneos --show-sdk-path) \
  -target arm64-apple-ios14.0 \
  -O \
  -framework SwiftUI \
  -framework UIKit \
  -framework Foundation \
  -o "$BUILD_DIR/$APP_NAME" \
  "$BUILD_DIR/Sources/main.swift"

echo "✅ 编译完成"

# 打包 IPA
mkdir -p "$BUILD_DIR/Payload/$APP_NAME.app"
cp "$BUILD_DIR/$APP_NAME" "$BUILD_DIR/Payload/$APP_NAME.app/"
cp "$PROJECT_DIR/ents.plist" "$BUILD_DIR/Payload/$APP_NAME.app/"

cat > "$BUILD_DIR/Payload/$APP_NAME.app/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>WatchPairFix</string>
	<key>CFBundleIdentifier</key>
	<string>com.lengye.watchpairfix</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleExecutable</key>
	<string>WatchPairFix</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>MinimumOSVersion</key>
	<string>14.0</string>
	<key>UIDeviceFamily</key>
	<array><integer>1</integer></array>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
</dict>
</plist>
EOF

cd "$BUILD_DIR"
ldid -Sents.plist "Payload/$APP_NAME.app/$APP_NAME" 2>/dev/null || true
zip -qry "$APP_NAME.ipa" Payload
rm -rf Payload

echo "✅ $BUILD_DIR/$APP_NAME.ipa 已生成"
open "$BUILD_DIR"
