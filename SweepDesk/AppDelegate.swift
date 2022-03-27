//
//  AppDelegate.swift
//  SweepDesk
//
//  Created by Yuichi Yoshida on 2022/03/27.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    @IBAction func toggle(sender: NSButton) {
        
        let current = getStatus()
        execute(flag: !current)
        restartFinder()
        if let button = self.statusItem.button {
            let current2 = getStatus()
            if current2 {
                button.image = NSImage(named: "normal")
            } else {
                button.image = NSImage(named: "hide")
            }
        }
    }
    
    func restartFinder() {
        
        let task = Process()
        task.launchPath = "/usr/bin/killall"
        let arguments = [
            "Finder"
        ]
        
        task.arguments = arguments
        
        task.launch()
        task.waitUntilExit()
        print(task.terminationStatus)
    }
    
    func execute(flag: Bool) {
        
        let status = flag ? "true" : "false"
        
            print("try to write - \(status)")
        
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        let arguments = [
            "write",
            "com.apple.finder",
            "CreateDesktop",
            status
        ]
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        task.arguments = arguments
        
        do {
        try task.run()
//        task.launch()
        task.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(decoding: outputData, as: UTF8.self)
        print(output)
        let error = String(decoding: errorData, as: UTF8.self)
        print(error)
        
        print(task.terminationStatus)
        } catch {
            print(error)
        }
    }
    
    func getStatus() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        let arguments = [
            "read",
            "com.apple.finder",
            "CreateDesktop"
        ]
        
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        let fileHandle = pipe.fileHandleForReading
        
        task.launch()
        task.waitUntilExit()
        do {
            guard let data = try fileHandle.readToEnd() else { throw NSError(domain: "com.sonson.error", code: 1) }
            if let string = String(data: data, encoding: .utf8) {
                print("defaults - read \(string)")
                print(string.count)
                if string == "true\n" {
                    return true
                } else {
                    return false
                }
            }
            return false
        } catch {
            print(error)
            return false
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let current = getStatus()
        
        if let button = self.statusItem.button {
            if current {
                button.image = NSImage(named: "normal")
            } else {
                button.image = NSImage(named: "hide")
            }
            button.target = self
            button.action = #selector(AppDelegate.toggle(sender:))
        }
        
        
//        self.statusItem.menu = NSMenu()
//        let menuItem = NSMenuItem()
//        menuItem.title = "Quit"
////        menuItem.action = #selector(MacOSBridge.quit(sender:))
//        menuItem.target = self
//        self.statusItem.menu!.addItem(menuItem)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

