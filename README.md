# iOS Picture-in-Picture Player POC

A proof of concept iOS app demonstrating automatic Picture-in-Picture (PiP) video playback that transitions to background mode.

## Features

- **Picture-in-Picture Video Playback**: Seamless PiP implementation using AVPlayerViewController and AVPictureInPictureController
- **Background Audio Support**: Configured audio session for continuous playback when app is backgrounded
- **Two PiP Approaches**:
  - **App Store Compliant**: User manually goes to home screen after PiP preparation
  - **Forced Background**: Automatic background transition (uses private API - not recommended for production)
- **Animated Visual Indicators**: Pulsing house icon and text to guide users when PiP is ready
- **Hidden Player Preparation**: Prepares video for PiP without showing player UI to users

## How It Works

### App Store Compliant Approach (Recommended)
1. User taps **"Prepare PiP (Then Press Home)"** button
2. App prepares video in hidden player (0.4s)
3. Animated visual indicator appears with pulsing house icon
4. User manually presses home button
5. PiP automatically starts on home screen

### Forced Background Approach (Testing Only)
1. User taps **"Force PiP & Background"** button
2. App prepares video in hidden player (0.4s)
3. App automatically goes to background using private API
4. PiP starts immediately on home screen

## Technical Implementation

- **Audio Session**: Configured for `.playback` category with `.moviePlayback` mode
- **Background Modes**: Enabled in Info.plist for audio processing
- **PiP Controller**: Uses AVPictureInPictureController with proper delegate handling
- **SwiftUI Integration**: Custom UIViewControllerRepresentable wrappers for AVPlayerViewController
- **Notification Handling**: Uses NotificationCenter to detect natural background transitions

## Requirements

- iOS 14.0+
- Xcode 15.0+
- Device with PiP support (iPad or iPhone)

## Setup

1. Clone the repository
2. Open `MyPiPPlayer.xcodeproj` in Xcode
3. Add your development team in project settings
4. Build and run on a physical device (PiP requires physical device)

## App Store Considerations

⚠️ **Important**: The red "Force PiP & Background" button uses private APIs (`UIApplication.shared.perform(#selector(NSXPCConnection.suspend))`) which may cause App Store rejection. Use only for testing purposes.

✅ **Production Ready**: The blue "Prepare PiP (Then Press Home)" button is App Store compliant and should be used in production apps.

## File Structure

```
MyPiPPlayer/
├── MyPiPPlayerApp.swift          # App entry point with audio session configuration
├── ContentView.swift             # Main UI with PiP implementation
├── Info.plist                    # Background modes configuration
├── sample_vid.mp4               # Test video file
└── Assets.xcassets/             # App icons and assets
```

## Key Components

- **PiPCoordinator**: ObservableObject managing PiP controller and callbacks
- **HiddenPiPPlayerView**: Hidden player view for seamless PiP preparation
- **VideoPlayerView**: Visible player view for regular playback
- **Animated Visual Cues**: Pulsing house icon with instructions

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

This is a proof of concept. Feel free to fork and experiment with different approaches to iOS PiP implementation.