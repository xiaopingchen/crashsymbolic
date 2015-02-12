//
//  ViewController.swift
//  CrashSymbolic
//
//  Created by xiaoping on 2/11/15.
//  Copyright (c) 2015 xiaoping. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {
    
    @IBOutlet weak var txtCrashInput: NSTextField!
    @IBOutlet weak var btnChoseCrashFile: NSButton!
    @IBOutlet weak var txtDsymInput: NSTextField!
    @IBOutlet weak var btnChoseDsymFile: NSButton!
    
    let crashFileUserDefaultKey = "crashFileUserDefaultPath"
    let dsymFileUserDefaultKey = "dsymFileUserDefaultPath"
    
    var resultWindow =  SymbolicResultWindowController(windowNibName: "SymbolicResultWindowController")
    var openPanel = NSOpenPanel()
    var symbolicatePath: NSString?
    
    @IBAction func symbolicateCrash(sender: AnyObject) {
        
        if (symbolicatePath == nil) { return }
        
        let cmd = "DEVELOPER_DIR=`xcode-select -print-path` \(self.symbolicatePath!)  \(self.txtCrashInput.stringValue) \(self.txtDsymInput.stringValue)"
        var task = NSTask()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c" , cmd]
        var outputPipe = NSPipe()
        var errorPipe = NSPipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.terminationHandler = { task -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                var resultContent = NSString(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
                self.resultWindow.symbolicResult = resultContent
                self.resultWindow.showWindow(nil)
            })
            
        }
        task.launch()
        
    }
    
    @IBAction func btnChoseDsymFilePressed(sender: NSButton) {
        openPanel.allowedFileTypes = ["dsym"]
        openPanel.allowsOtherFileTypes = false
        openPanel.beginSheetModalForWindow(self.view.window!, completionHandler: { [unowned self](result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                self.txtDsymInput.stringValue = self.openPanel.URL!.path!
                NSUserDefaults.standardUserDefaults().setObject(self.txtDsymInput.stringValue, forKey: self.dsymFileUserDefaultKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        })
    }
    
    @IBAction func btnChoseCrashFilePressed(sender: NSButton) {
        openPanel.allowedFileTypes = ["crash"]
        openPanel.beginSheetModalForWindow(self.view.window!, completionHandler: {[unowned self] (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                self.txtCrashInput.stringValue = self.openPanel.URL!.path!
                NSUserDefaults.standardUserDefaults().setObject(self.txtCrashInput.stringValue, forKey: self.crashFileUserDefaultKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.symbolicatePath = findSymbolicateCrash();
        if self.symbolicatePath == nil {
            let alert = NSAlert()
            alert.alertStyle =  NSAlertStyle.WarningAlertStyle
            alert.messageText = "haven't find symbolicatecrash batch file, can't symbolicate crash now"
            alert.runModal()
        }
        
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsOtherFileTypes = false
        var crashFilePath = NSUserDefaults.standardUserDefaults().objectForKey(self.crashFileUserDefaultKey)?.stringValue
        if crashFilePath != nil {
            self.txtCrashInput.stringValue = crashFilePath!
        }
        
        var dsymFilePath = NSUserDefaults.standardUserDefaults().objectForKey(self.crashFileUserDefaultKey)?.dsymFileUserDefaultKey
        if dsymFilePath != nil {
            self.txtDsymInput.stringValue = dsymFilePath!
        }
    }
    
    func findSymbolicateCrash() -> NSString? {
        var fileManager = NSFileManager.defaultManager()
        var dir = "Applications"
        var apps = fileManager.contentsOfDirectoryAtPath("/Applications", error: nil)
        var symbolicatePath: NSString?
        for app in apps! {
            var appPath = app as String
            if appPath.hasPrefix("Xcode") {
                symbolicatePath = "/Applications/\(appPath)/Contents/SharedFrameworks/DTDeviceKitBase.framework/Versions/A/Resources/symbolicatecrash"
                if fileManager.fileExistsAtPath(symbolicatePath! + "symbolicatecrash") {
                    break
                }
                
            }
        }
        
        return symbolicatePath;
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

