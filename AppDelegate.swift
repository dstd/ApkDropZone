//
//  AppDelegate.swift
//  ApkDropZone
//
//  Created by dstd on 12.05.15.
//  Copyright (c) 2015 stdlabs. All rights reserved.
//

import Cocoa

func rangeForString(string: String) -> NSRange {
    return NSMakeRange(0, count(string))
}

extension String {
    func substringWithRange(range: NSRange) -> String {
        return (self as NSString).substringWithRange(range);
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var outputLog: NSTextField!
    
    var launchPath: String!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        launchPath = "~/Library/Android/sdk/platform-tools/adb".stringByExpandingTildeInPath;
        if !NSFileManager.defaultManager().fileExistsAtPath(launchPath!) {
            launchPath = "adb"
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    func writeLog(string: String) {
        self.outputLog.stringValue = self.outputLog.stringValue + string + "\n"
    }
    
    func installApk(filename: String) {
        writeLog("Installing \(filename)")
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            var outputTotal = String()
            
            let outputPipe = NSPipe()
            let outputStream = outputPipe.fileHandleForReading;
            
            var task = NSTask()
            task.launchPath = self.launchPath
            task.arguments = ["install", "-r", filename];
            task.standardOutput = outputPipe;
            
            let exception = Exceptions.try
                { () -> Void in
                    task.launch()
                    
                    while task.running {
                        let ouputData = outputStream.availableData
                        let ouputString = NSString(data: ouputData, encoding: NSUTF8StringEncoding) as! String
                        outputTotal += ouputString
                    }
                }
            
            if exception != nil {
                self.writeLog("Failed to start ADB. Check PATH or move to ~/Library/Android/sdk/platform-tools/adb")
                return;
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                if let regex = NSRegularExpression(pattern: "Failure \\[(.*)\\]", options: NSRegularExpressionOptions(0), error: nil) {
                    let lines = outputTotal.componentsSeparatedByString("\n")
                    let errors = lines.filter { regex.firstMatchInString($0, options: NSMatchingOptions(0), range: rangeForString($0)) != nil }
                    
                    if errors.count > 0 {
                        let errorLine = errors[0];
                        let error: String
                        if let errorItem = regex.firstMatchInString(errorLine, options: NSMatchingOptions(0), range: rangeForString(errorLine)) {
                            error = errorLine.substringWithRange(errorItem.rangeAtIndex(1))
                        }
                        else {
                            error = "UNKNOWN ERROR"
                        }
                        self.writeLog("Failed: \(error)")
                    }
                    else {
                        self.writeLog("Done")
                    }
                }
            }
        }
    }

    func application(sender: NSApplication, openFile filename: String) -> Bool {
        installApk(filename);
        return true;
    }

}

