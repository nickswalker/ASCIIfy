//
//  Copyright for portions of ASCIIfy are held by Barış Koç, 2014 as part of
//  project BKAsciiImage and Amy Dyer, 2012 as part of project Ascii. All other copyright
//  for ASCIIfy are held by Nick Walker, 2016.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import AppKit
import ASCIIfy

class WindowController: NSWindowController {
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var fontSizeSlider: NSSlider!

    var viewController: ViewController {
        return self.window!.contentViewController! as! ViewController
    }

    override func windowDidLoad() {
        // Configure demo image

        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("flower", ofType: "jpg")!
        let image = NSImage(contentsOfFile: path)!
        fontSizeSlider.maxValue = Double(image.size.width) / 100.0
        viewController.inputImage = image
    }

    @IBAction func didChangeFontSize(sender: NSSlider) {
        let fontSize = CGFloat(sender.floatValue)
        viewController.fontSize = fontSize
    }

    @IBAction func didChangeColorMode(sender: NSSegmentedControl) {
        let selected = sender.selectedSegment
        let mode: ASCIIConverter.ColorMode = {
            switch selected {
            case 1:
                return ASCIIConverter.ColorMode.GrayScale
            case 2:
                return ASCIIConverter.ColorMode.BlackAndWhite
            default:
                return ASCIIConverter.ColorMode.Color
            }
        }()
        viewController.colorMode = mode
    }

    func openDocument(sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.message = "Select an image"
        openPanel.beginSheetModalForWindow(window!) { result in
            if result == NSFileHandlingPanelOKButton {
                let url = openPanel.URLs[0]
                let image = NSImage(contentsOfURL: url)
                self.fontSizeSlider.maxValue = Double(image!.size.width) / 100.0
                self.viewController.inputImage = image

            }
        }
    }
}