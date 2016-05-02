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

import Cocoa
import ASCIIfy
import ImageIO
import Quartz

class ViewController: NSViewController {

    @IBOutlet weak var imageView: IKImageView!

    var fontSize: CGFloat = 20.0 {
        didSet(oldValue) {
            processInput()
        }
    }

    var inputImage: NSImage? {
        didSet(oldValue) {
            processInput()
        }
    }

    var colorMode: ASCIIConverter.ColorMode = .Color {
        didSet(oldValue) {
            processInput()
        }
    }

    private var outputImage: CGImage? {
        didSet(oldValue) {
            self.imageView.setImage(outputImage, imageProperties: [:])
        }
    }

    private var displayingOutput = true {
        didSet(oldValue) {
            if displayingOutput {
                self.imageView.setImage(outputImage, imageProperties: [:])
            }
            else {
                self.imageView.setImage(toCGImage(inputImage!), imageProperties: [:])
            }
        }
    }

    private func processInput() {
        let font = NSFont(name: ASCIIConverter.defaultFont.fontName, size: fontSize)!
        inputImage?.fy_asciiImageWith(font, colorMode: colorMode){
            asciified in
            self.outputImage = self.toCGImage(asciified)
                                            
        }
    }

    private func toCGImage(image: NSImage) -> CGImage {
        var rect = NSRect(origin: CGPointZero, size: image.size)
        return image.CGImageForProposedRect(&rect, context: nil, hints: nil)!
    }

    @IBAction func didClickView(sender: NSClickGestureRecognizer) {
        displayingOutput = !displayingOutput
    }

}


extension ViewController {

}
