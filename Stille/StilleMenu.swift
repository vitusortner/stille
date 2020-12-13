import Cocoa
import Foundation

final class StilleMenu : NSMenu {
    
    private let spotifyItem = NSMenuItem(title: "Spotify", action: #selector(selectApp(sender:)), keyEquivalent: "")
    private let soundCloudItem = NSMenuItem(title: "Chrome - SoundCloud", action: #selector(selectApp(sender:)), keyEquivalent: "")
    
    private var timer: Timer?
    private var isRunning = false
    private var selectedApp = "Spotify"
    private var remainingSeconds = 0
    private let secondsPerMinute = 60
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(title: "Stille")
        
        let isRunningItem = NSMenuItem(title: "Not running", action: nil, keyEquivalent: "")
        self.addItem(isRunningItem)
        
        self.addItem(NSMenuItem.separator())
        
        let minutesItem = NSMenuItem(title: "Pause music in", action: nil, keyEquivalent: "")
        let minutesSubmenu = NSMenu()
        
        let shortDuration = NSMenuItem(title: "15 minutes", action: #selector(setMinutes(sender:)), keyEquivalent: "")
        shortDuration.representedObject = 15
        shortDuration.target = self
        minutesSubmenu.addItem(shortDuration)
        
        let mediumDuration = NSMenuItem(title: "25 minutes", action: #selector(setMinutes(sender:)), keyEquivalent: "")
        mediumDuration.representedObject = 25
        mediumDuration.target = self
        minutesSubmenu.addItem(mediumDuration)
        
        let longDuration = NSMenuItem(title: "45 minutes", action: #selector(setMinutes(sender:)), keyEquivalent: "")
        longDuration.representedObject = 45
        longDuration.target = self
        minutesSubmenu.addItem(longDuration)
        
        minutesItem.submenu = minutesSubmenu
        self.addItem(minutesItem)
        
        let appItem = NSMenuItem(title: "App", action: nil, keyEquivalent: "")
        let appSubmenu = NSMenu()
        
        spotifyItem.state = .on
        spotifyItem.target = self
        appSubmenu.addItem(spotifyItem)
        
        soundCloudItem.target = self
        appSubmenu.addItem(soundCloudItem)
        
        appItem.submenu = appSubmenu
        self.addItem(appItem)
        
        self.addItem(NSMenuItem.separator())
        
        self.addItem(NSMenuItem(title: "Stille Ger. silence", action: nil, keyEquivalent: ""))
        let quitItem = NSMenuItem(title: "Quit", action: #selector(terminate), keyEquivalent: "")
        quitItem.target = self
        self.addItem(quitItem)
        
        let tickTimer = Timer(timeInterval: 1, repeats: true) { timer in
            if self.isRunning && self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            }
            isRunningItem.title = self.isRunning ? "Stille in \(self.remainingSeconds / self.secondsPerMinute) minutes" : "Not running"
        }
        RunLoop.main.add(tickTimer, forMode: .common)
    }
    
    @objc private func setMinutes(sender: NSMenuItem) {
        print("setMinutes(\(sender)")
        
        guard let minutes = sender.representedObject as? Int else {
            print("\(sender.title) is not an integer")
            return
        }
        
        if isRunning {
            print("Invalidating active timer")
            timer?.invalidate()
            timer = nil
        }
        
        isRunning = true
        remainingSeconds = minutes * secondsPerMinute
        
        timer = Timer(timeInterval: Double(minutes * secondsPerMinute), repeats: false) { timer in
            print("Timer elapsed")
            
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
        RunLoop.main.add(timer!, forMode: .common)
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
    
    @objc private func terminate() {
        NSApp.terminate(nil)
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
