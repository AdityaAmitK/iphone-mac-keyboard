#!/bin/zsh
set -eu

readonly project="/Users/aditya/Developer/Personal_Projects/iPhoneMacKeyboard"
readonly developer="/Applications/Xcode-beta.app/Contents/Developer"
readonly device="00008120-00014DEC022A601E"
readonly team="M9K2GT5S6F"
readonly derived="$HOME/Library/Caches/iPhoneMacKeyboard"

export DEVELOPER_DIR="$developer"

# A missed run is harmless; launchd retries the next day.
xcrun devicectl list devices | grep "$device" | grep -Eq "available|connected" || exit 0

xcodebuild -quiet \
  -project "$project/iPhoneMacKeyboard.xcodeproj" \
  -scheme PhoneKeyboard \
  -configuration Debug \
  -destination "id=$device" \
  -derivedDataPath "$derived" \
  DEVELOPMENT_TEAM="$team" \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration \
  build

xcrun devicectl device install app \
  --device "$device" \
  "$derived/Build/Products/Debug-iphoneos/PhoneKeyboard.app"
