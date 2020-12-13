//
//  ContentView.swift
//  Stille
//
//  Created by Vitus on 28.09.20.
//  Copyright © 2020 Vitus. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var seconds: Int = 0
    
    @State private var remainingSeconds: Int?
    
    private var numberProxy: Binding<String> {
         Binding<String>(
             get: { String(seconds) },
             set: {
                if let sec = Int($0) {
                    seconds = sec
                } else {
                    seconds = 0
                }
             }
         )
     }
    
    var body: some View {
        VStack {
            if let remainingSeconds = remainingSeconds, remainingSeconds >= 0 {
                Text("\(remainingSeconds)")
            }
            HStack {
                TextField("Take a break in:", text: numberProxy)
                Button("Start") {
                    remainingSeconds = seconds
                    startCountdown()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(seconds))) {
                        var error: NSDictionary?
                        if let scriptObject = NSAppleScript(source: toggleSoundCloudPlayback) {
                            scriptObject.executeAndReturnError(&error)
                            if (error != nil) {
                                print("Error: \(String(describing: error))")
                            }
                            
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if (remainingSeconds != nil) {
                if remainingSeconds! <= 0 {
                    timer.invalidate()
                }
                remainingSeconds! -= 1
            }
        }
    }
    
    private let toggleSpotifyPlayback = """
        tell application "Spotify"
            playpause
        end tell
    """
    
    private let toggleSoundCloudPlayback = """
        tell application "Google Chrome"
            repeat with theTab in every tab in every window
                if URL of theTab starts with "https://soundcloud.com" then
                    execute theTab javascript "var el = document.querySelector('button.playControls__" & "play" & "'); el && el.click()"
                    return
                end if
            end repeat
        end tell
    """
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
