//
//  SymbolicResultWindowController.swift
//  CrashSymbolic
//
//  Created by xiaoping on 2/12/15.
//  Copyright (c) 2015 xiaoping. All rights reserved.
//

import Cocoa

class SymbolicResultWindowController: NSWindowController {

    @IBOutlet var textViewResult: NSTextView!
    var symbolicResult: String!

    @IBAction func saveToFile(sender: AnyObject) {
                let savePanel = NSSavePanel();
                savePanel.allowedFileTypes = ["crash"]
                savePanel.allowsOtherFileTypes = false
                savePanel.directoryURL = NSURL(fileURLWithPath: NSHomeDirectory()+"/Desktop")
                savePanel.nameFieldStringValue = "symboliced"
                savePanel.beginSheetModalForWindow(self.window!, completionHandler:{ result -> () in
                    if result == NSFileHandlingPanelOKButton {
                        self.symbolicResult.writeToURL(savePanel.URL!, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
                    }
        
                })

    }
    override func windowDidLoad() {
        super.windowDidLoad()

        textViewResult.string = symbolicResult
        textViewResult.editable = false
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
}
