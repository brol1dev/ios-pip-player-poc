//
//  MyPiPPlayerApp.swift
//  MyPiPPlayer
//
//  Created by Eric on 7/16/25.
//

import SwiftUI
import AVFoundation

@main
struct MyPiPPlayerApp: App {
    init() {
        configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .moviePlayback
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}
