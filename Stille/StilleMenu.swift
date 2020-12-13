import Cocoa
import Foundation

final class StilleMenu : NSMenu {
    
    private let spotifyItem = NSMenuItem(title: "Spotify", action: #selector(selectApp(sender:)), keyEquivalent: "")
    private let soundCloudItem = NSMenuItem(title: "Chrome - SoundCloud", action: #selector(selectApp(sender:)), keyEquivalent: "")
    
    private var isRunning = false
    private var selectedApp = "Spotify"
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(title: "Stille")
        
        // TODO replace X with actual time
        let isRunningItem = NSMenuItem(title: isRunning ? "Stille in X minutes" : "Not running", action: nil, keyEquivalent: "")
        self.addItem(isRunningItem)
        let timer = Timer(timeInterval: TimeInterval.init(1), repeats: true) { timer in
            print("DRAW")
            isRunningItem.title = self.isRunning ? "Stille in X minutes" : "Not running"
        }
        RunLoop.main.add(timer, forMode: .common)
        
        self.addItem(NSMenuItem.separator())
        
        let minutesItem = NSMenuItem(title: "Pause music in", action: nil, keyEquivalent: "")
        let minutesSubmenu = NSMenu()
        let fifteen = NSMenuItem(title: "15 minutes", action: #selector(setMinutes(sender:)), keyEquivalent: "")
        fifteen.representedObject = 15
        fifteen.target = self
        minutesSubmenu.addItem(fifteen)
        
        let twentyfive = NSMenuItem(title: "25 minutes", action: #selector(setMinutes(sender:)), keyEquivalent: "")
        fifteen.representedObject = 25
        twentyfive.target = self
        minutesSubmenu.addItem(twentyfive)
        
        let fourtyfive = NSMenuItem(title: "45 minutes", action: #selector(setMinutes(sender:)), keyEquivalent: "")
        fifteen.representedObject = 45
        fourtyfive.target = self
        minutesSubmenu.addItem(fourtyfive)
        
        minutesItem.submenu = minutesSubmenu
        self.addItem(minutesItem)
        
        self.addItem(NSMenuItem.separator())
        
        let appItem = NSMenuItem(title: "App", action: nil, keyEquivalent: "")
        let appSubmenu = NSMenu()
        
        spotifyItem.state = .on
        spotifyItem.target = self
        appSubmenu.addItem(spotifyItem)
        
        soundCloudItem.target = self
        appSubmenu.addItem(soundCloudItem)
        
        appItem.submenu = appSubmenu
        self.addItem(appItem)
        
        // TODO self.addItem - Stille - silence
    }
    
    @objc private func setMinutes(sender: NSMenuItem) {
        print("setMinutes(\(sender)")
        
        guard let minutes = sender.representedObject as? Int else {
            print("\(sender.title) is not an integer.")
            return
        }
        isRunning = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(minutes))) {
            self.isRunning = false
            
            let toggleScript: String
            switch self.selectedApp {
            case "Spotify": toggleScript = self.toggleSpotifyPlayback
            case "Chrome - SoundCloud": toggleScript = self.toggleSoundCloudPlayback
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

    @objc private func selectApp(sender: NSMenuItem) {
        print("selectApp(\(sender))")
        
        selectedApp = sender.title
        
        switch selectedApp {
        case "Spotify":
            spotifyItem.state = .on
            soundCloudItem.state = .off
        case "Chrome - SoundCloud":
            spotifyItem.state = .off
            soundCloudItem.state = .on
        default: return
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
