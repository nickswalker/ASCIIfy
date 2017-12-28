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

        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "flower", ofType: "jpg")!
        let image = NSImage(contentsOfFile: path)!
        fontSizeSlider.maxValue = Double(image.size.width) / 50.0
        fontSizeSlider.doubleValue = fontSizeSlider.maxValue
        viewController.inputImage = image
    }

    @IBAction func didChangeFontSize(_ sender: NSSlider) {
        let fontSize = CGFloat(sender.floatValue)
        viewController.fontSize = fontSize
    }

    @IBAction func didChangeColorMode(_ sender: NSSegmentedControl) {
        let selected = sender.selectedSegment
        let mode: ASCIIConverter.ColorMode = {
            switch selected {
            case 1:
                return ASCIIConverter.ColorMode.grayScale
            case 2:
                return ASCIIConverter.ColorMode.blackAndWhite
            default:
                return ASCIIConverter.ColorMode.color
            }
        }()
        viewController.colorMode = mode
    }

    func openDocument(_ sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.message = "Select an image"
        openPanel.beginSheetModal(for: window!) { result in
            if result.rawValue == NSFileHandlingPanelOKButton {
                let url = openPanel.urls[0]
                let image = NSImage(contentsOf: url)

                self.fontSizeSlider.maxValue = Double(image!.size.width) / 50.0
                self.fontSizeSlider.doubleValue = self.fontSizeSlider.maxValue
                self.viewController.inputImage = image

            }
        }
    }
}
