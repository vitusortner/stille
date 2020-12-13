import SwiftUI

struct ContentView: View {
    
    @State private var seconds = 0
    
    @State private var remainingSeconds: Int?
    
    private var secondsBinding: Binding<String> {
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
    
    private let playbackApps = ["Spotify", "SoundCloud"]
    
    @State private var selectedPlaybackAppIndex = 0
    
    var body: some View {
        VStack {
            if let remainingSeconds = remainingSeconds, remainingSeconds >= 0 {
                Text("\(remainingSeconds)")
            }
            HStack {
                TextField("Take a break in:", text: secondsBinding)
                Button("Start") {
                    remainingSeconds = seconds
                    startCountdown()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(seconds))) {
                        let toggleScript: String
                        
                        switch playbackApps[selectedPlaybackAppIndex] {
                        case "Spotify": toggleScript = toggleSpotifyPlayback
                        case "SoundCloud": toggleScript = toggleSoundCloudPlayback
                        default: return
                        }
                        
                        var error: NSDictionary?
                        if let scriptObject = NSAppleScript(source: toggleScript) {
                            scriptObject.executeAndReturnError(&error)
                            if (error != nil) {
                                print("Error: \(String(describing: error))")
                            }
                            
                        }
                    }
                }
            }
            Picker(selection: $selectedPlaybackAppIndex, label: Text("Music App")) {
                ForEach(0 ..< playbackApps.count) {
                    Text(playbackApps[$0])
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
