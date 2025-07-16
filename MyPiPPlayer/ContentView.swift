//
//  ContentView.swift
//  MyPiPPlayer
//
//  Created by Eric on 7/16/25.
//

import SwiftUI
import AVKit
import AVFoundation

class PiPCoordinator: ObservableObject {
    var pipController: AVPictureInPictureController?
    var onPiPStarted: (() -> Void)?
    
    func startPiP() {
        guard let pipController = pipController else {
            print("PiP controller not available")
            return
        }
        
        if AVPictureInPictureController.isPictureInPictureSupported() && !pipController.isPictureInPictureActive {
            pipController.startPictureInPicture()
            print("Starting PiP")
        }
    }
}

struct ContentView: View {
    @State private var player: AVPlayer?
    @State private var showPlayer = false
    @State private var showHiddenPlayer = false
    @State private var pipReadyToStart = false
    @State private var showPiPReadyIndicator = false
    @State private var pulseAnimation = false
    @StateObject private var pipCoordinator = PiPCoordinator()
    
    var body: some View {
        ZStack {
            // Background layer with hidden player
            if showHiddenPlayer, let player = player {
                HiddenPiPPlayerView(player: player, pipCoordinator: pipCoordinator)
                    .frame(width: 300, height: 200)
            }
            
            // UI layer
            VStack(spacing: 20) {
                Text("PiP Video Player")
                    .font(.title)
                    .fontWeight(.bold)
                
                if showPlayer, let player = player {
                    VideoPlayerView(player: player, pipCoordinator: pipCoordinator)
                        .frame(height: 300)
                    
                    Button("Stop Video") {
                        player.pause()
                        showPlayer = false
                        self.player = nil
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
//                    Button(action: startRegularPlayback) {
//                        Text("Test Regular Video Playback")
//                            .font(.title2)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.green)
//                            .cornerRadius(10)
//                    }
                    
                    Button(action: startPiPPlayback) {
                        Text("Prepare PiP (Then Press Home)")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: startPiPPlaybackForced) {
                        Text("Force PiP & Background")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    
                    if showPiPReadyIndicator {
                        VStack(spacing: 15) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseAnimation)
                            
                            Text("Ready! Go to Home now!")
                                .font(.headline)
                                .foregroundColor(.orange)
                                .opacity(pulseAnimation ? 1.0 : 0.7)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseAnimation)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            if pipReadyToStart {
                print("App went to background - starting PiP")
                pipCoordinator.startPiP()
                pipReadyToStart = false
                showPiPReadyIndicator = false
                pulseAnimation = false
            }
        }
    }
    
    private func startPiPPlayback() {
        guard let url = Bundle.main.url(forResource: "sample_vid", withExtension: "mp4") else {
            print("Video file not found")
            return
        }
        
        print("Preparing PiP playback")
        player = AVPlayer(url: url)
        showHiddenPlayer = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.player?.play()
            print("Video started playing (hidden)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("Player ready - PiP will start when you go to home screen")
                self.pipReadyToStart = true
                self.showPiPReadyIndicator = true
                self.pulseAnimation = true
            }
        }
    }
    
    private func startPiPPlaybackForced() {
        guard let url = Bundle.main.url(forResource: "sample_vid", withExtension: "mp4") else {
            print("Video file not found")
            return
        }
        
        print("Starting forced PiP playback")
        player = AVPlayer(url: url)
        showHiddenPlayer = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.player?.play()
            print("Video started playing (hidden)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("Player ready, forcing background")
                self.forceBackground()
                
                // Start PiP immediately after going to background
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.startPictureInPicture()
                }
            }
        }
    }
    
    private func startPictureInPicture() {
        print("Attempting to start PiP")
        pipCoordinator.startPiP()
    }
    
    private func forceBackground() {
        print("Forcing app to background")
        
        // WARNING: This uses private API and may cause App Store rejection
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        
        // ALTERNATIVE: App Store compliant approaches (uncomment to use):
        
        // Option 1: Let user manually go to home screen
        // print("PiP started - please press home button to see PiP on home screen")
        
        // Option 2: Show alert instructing user
        // DispatchQueue.main.async {
        //     let alert = UIAlertController(title: "PiP Started", 
        //                                   message: "Press the home button to see video in Picture-in-Picture mode", 
        //                                   preferredStyle: .alert)
        //     alert.addAction(UIAlertAction(title: "OK", style: .default))
        //     if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        //        let window = windowScene.windows.first {
        //         window.rootViewController?.present(alert, animated: true)
        //     }
        // }
    }
    
    private func startRegularPlayback() {
        guard let url = Bundle.main.url(forResource: "sample_vid", withExtension: "mp4") else {
            print("Video file not found")
            return
        }
        
        print("Video URL: \(url)")
        player = AVPlayer(url: url)
        showPlayer = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            player?.play()
            print("Started playing video")
        }
    }
}

struct PiPVideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer?
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = true
        playerViewController.delegate = context.coordinator
        return playerViewController
    }
    
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        if let player = player {
            playerViewController.player = player
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                player.play()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if AVPictureInPictureController.isPictureInPictureSupported(),
                       let playerLayer = playerViewController.view.layer.sublayers?.first(where: { $0 is AVPlayerLayer }) as? AVPlayerLayer {
                        let pipController = AVPictureInPictureController(playerLayer: playerLayer)
                        pipController?.startPictureInPicture()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        }
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            
        }
        
        func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
            
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    let pipCoordinator: PiPCoordinator
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        print("VideoPlayerView makeUIViewController called")
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let playerLayer = playerViewController.view.layer.sublayers?.first(where: { $0 is AVPlayerLayer }) as? AVPlayerLayer {
                pipCoordinator.pipController = AVPictureInPictureController(playerLayer: playerLayer)
                pipCoordinator.pipController?.delegate = context.coordinator
                print("PiP controller created and assigned to coordinator")
            }
        }
        
        return playerViewController
    }
    
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        print("VideoPlayerView updateUIViewController called")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, AVPictureInPictureControllerDelegate {
        func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            print("PiP started successfully")
        }
        
        func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            print("PiP stopped")
        }
    }
}

struct HiddenPiPPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    let pipCoordinator: PiPCoordinator
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        print("HiddenPiPPlayerView makeUIViewController called")
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = true
        playerViewController.showsPlaybackControls = false
        
        return playerViewController
    }
    
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        print("HiddenPiPPlayerView updateUIViewController called")
        
        // Try to find the player layer after the view is updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.findPlayerLayer(in: playerViewController, coordinator: context.coordinator)
        }
    }
    
    private func findPlayerLayer(in playerViewController: AVPlayerViewController, coordinator: Coordinator) {
        print("Searching for player layer...")
        
        // Try multiple approaches to find the player layer
        if let playerLayer = findPlayerLayerRecursively(in: playerViewController.view) {
            print("Found player layer!")
            pipCoordinator.pipController = AVPictureInPictureController(playerLayer: playerLayer)
            pipCoordinator.pipController?.delegate = coordinator
            print("Hidden PiP controller created and assigned")
        } else {
            print("Player layer not found")
        }
    }
    
    private func findPlayerLayerRecursively(in view: UIView) -> AVPlayerLayer? {
        // Check current view's layer
        if let playerLayer = view.layer as? AVPlayerLayer {
            return playerLayer
        }
        
        // Check sublayers
        if let sublayers = view.layer.sublayers {
            for sublayer in sublayers {
                if let playerLayer = sublayer as? AVPlayerLayer {
                    return playerLayer
                }
            }
        }
        
        // Check subviews recursively
        for subview in view.subviews {
            if let playerLayer = findPlayerLayerRecursively(in: subview) {
                return playerLayer
            }
        }
        
        return nil
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(pipCoordinator: pipCoordinator)
    }
    
    class Coordinator: NSObject, AVPictureInPictureControllerDelegate {
        let pipCoordinator: PiPCoordinator
        
        init(pipCoordinator: PiPCoordinator) {
            self.pipCoordinator = pipCoordinator
        }
        
        func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            print("Hidden PiP started successfully")
            pipCoordinator.onPiPStarted?()
        }
        
        func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            print("Hidden PiP stopped")
        }
    }
}

#Preview {
    ContentView()
}
