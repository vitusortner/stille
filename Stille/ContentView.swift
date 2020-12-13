//
//  ContentView.swift
//  Stille
//
//  Created by Vitus on 28.09.20.
//  Copyright © 2020 Vitus. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var minutes: Int = 0
    
    @State private var countdown: Int?
    
    private var numberProxy: Binding<String> {
         Binding<String>(
             get: { String(minutes) },
             set: {
                if let min = Int($0) {
                    minutes = min
                } else {
                    minutes = 0
                }
             }
         )
     }
    
    var body: some View {
        VStack {
            if countdown != nil && !(countdown! < 0) {
                Text("\(countdown!)")
            }
            HStack {
                TextField("Take a break in:", text: numberProxy)
                Button("Start") {
                    let seconds = minutes // * 60
                    countdown = seconds
                    startCountdown()
                    
                    print(seconds)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(seconds))) {
                        let togglePlayback = """
                            tell application "Spotify"
                                playpause
                            end tell
                        """
                        var error: NSDictionary?
                        if let scriptObject = NSAppleScript(source: togglePlayback) {
                            scriptObject.executeAndReturnError(&error)
                            if (error != nil) {
                                print("Error \(String(describing: error))")
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
            if (countdown != nil) {
                countdown! -= 1
                
                if countdown! <= 0 {
                    timer.invalidate()
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
