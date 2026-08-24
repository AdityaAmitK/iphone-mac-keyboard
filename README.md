# iPhone Mac Keyboard

Use your iPhone's software keyboard to type into the focused app on your Mac.

The project contains two dependency-free SwiftUI apps. They discover each other with
Multipeer Connectivity, encrypt the connection, and require approval on the Mac before
the iPhone can send input.

## Requirements

- Xcode 16 or newer
- iOS 17 or newer
- macOS 14 or newer
- Both devices on the same nearby network with Bluetooth enabled

## Run it

1. Open `iPhoneMacKeyboard.xcodeproj` in Xcode.
2. Select the **MacReceiver** scheme and run it on your Mac.
3. Grant Accessibility access when macOS asks. If needed, open **System Settings →
   Privacy & Security → Accessibility** and enable MacReceiver, then restart it.
4. Select the **PhoneKeyboard** scheme, choose your connected iPhone, set your
   development team under Signing & Capabilities, and run it.
5. Pick your Mac on the phone and approve the connection on the Mac.
6. Put the cursor in any Mac text field, tap the keyboard area on the phone, and type.

Modifier buttons latch for one keystroke. Tap a modifier twice to lock it; tap it again
to release it. This makes shortcuts such as Command-C and Command-Shift-4 practical.

## Security

Sessions use Multipeer Connectivity's required encryption. The Mac displays the
connecting device name and requires local confirmation. Only one phone can be connected
at a time, and input is ignored unless Accessibility permission is active.

## Limitations

- This is intended for nearby personal devices, not remote access over the internet.
- Some system-reserved shortcuts cannot be synthesized by third-party apps.
- The Mac receiver must remain running in the menu bar.

## License

MIT
