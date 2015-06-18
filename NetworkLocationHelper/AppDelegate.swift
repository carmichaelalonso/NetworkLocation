//
//  AppDelegate.swift
//  NetworkLocationHelper
//
//  Created by Cameron Carmichael Alonso on 18/06/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

extension String {
    public func split(separator: String) -> [String] {
        if separator.isEmpty {
            return map(self) { String($0) }
        }
        if var pre = self.rangeOfString(separator) {
            var parts = [self.substringToIndex(pre.startIndex)]
            while let rng = self.rangeOfString(separator, range: pre.endIndex..<endIndex) {
                parts.append(self.substringWithRange(pre.endIndex..<rng.startIndex))
                pre = rng
            }
            parts.append(self.substringWithRange(pre.endIndex..<endIndex))
            return parts
        } else {
            return [self]
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    func changedItem(sender:NSMenuItem) {
        println(sender.keyEquivalent)
        

        let action = "do shell script \"scselect " + sender.keyEquivalent + "\""
        println(action)
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: action) {
            if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error) {
                    
                    let stringArray = output.stringValue
                    println(stringArray)
                    
                    determineActiveNetworkConfigs()
                    
            } else if (error != nil) {
                println("error: \(error)")
            }
        }

        
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        //icon
        let icon = NSImage(named: "statusIcon")
        //icon!.setTemplate(true)
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        determineActiveNetworkConfigs()
    }
    
    func determineActiveNetworkConfigs() {
        
        //run applescript to determine active networks
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("scselect", ofType: "sc")
        let content = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: content!) {
            if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error) {
                    
                    let stringArray = output.stringValue?.split("\r")
                    
                    statusMenu.removeAllItems()
                    
                    for var i = 1; i < stringArray!.count; i++
                    {
                        var currentString = stringArray![i]
                        var newString = currentString.split("(")[1]
                        var finalString = newString.split(")")[0] //name
                        var id = currentString.split("(")[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) //id number and selected star
                        
                        var menuItem = NSMenuItem(title: finalString, action: nil, keyEquivalent: id)
                        menuItem.tag = i
                        
                        if id.rangeOfString("*") != nil{
                            //currently selected - set enabled to no
                            menuItem.enabled = false
                            menuItem.title = finalString + " (selected)"
                        } else {
                            menuItem.enabled = true
                            menuItem.action = Selector("changedItem:")
                        }
                        
                        statusMenu.addItem(menuItem)
                        
                    }
                    
                    //stringArray.removeAtIndex(0)
                    
                    println(stringArray)
            } else if (error != nil) {
                println("error: \(error)")
            }
        }

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

