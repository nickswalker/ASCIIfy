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

#if os(OSX)
    import CoreText
    public typealias Font = NSFont
    public typealias Image = NSImage
    public typealias Color = NSColor

    public extension NSFont {
        public func withSize(_ size: Float) -> NSFont {
            return NSFont(name: self.fontName, size: CGFloat(size))!
        }
    }
#elseif os(iOS)
    import UIKit
    public typealias Font = UIFont
    public typealias Image = UIImage
    public typealias Color = UIColor
#endif

public typealias ImageHandler = ((Image) -> Void)
public typealias StringHandler = ((String) -> Void)

/// Converts images to ASCII art as a string or an image
open class ASCIIConverter {
    var lut: LookupTable = LuminanceLookupTable()
    open static var defaultFont = Font(name: "Courier", size: 12.0)!
    open var font = ASCIIConverter.defaultFont
    open var backgroundColor = Color.clear
    open var columns: Int?
    open var colorMode = ColorMode.color
    fileprivate func gridWidth(_ width: Int) -> Int {
        if columns ?? 0 <= 0 {
            return Int(CGFloat(width) / font.pointSize)
        } else {
            return Int(columns!)
        }
    }
    
    public enum ColorMode {
        case blackAndWhite,
        grayScale,
        color
    }

    public init() {
    }

    public init(lut: LookupTable) {
        self.lut = lut
    }

    fileprivate func isTransparent() -> Bool {
        return backgroundColor == Color.clear
    }

    #if os(iOS)
    private func configureAttributes(_ attributes: inout [String: Any], color: Color) {
        attributes[NSForegroundColorAttributeName] = color
    }

    #elseif os(OSX)
    fileprivate func configureAttributes(_ attributes: inout [AnyHashable: Any], color: Color){
        attributes[kCTForegroundColorAttributeName as AnyHashable] = color.cgColor
    }
    #endif

    fileprivate func stringsAndColorsToContext(_ data: [[(String, Color)]], size: CGSize, bgColor: Color, font: Font) -> Image {
        // Setup background
        let ctxRect = CGRect(origin: CGPoint.zero, size: size)

        let bitsPerComponent = 8
        let bytesPerRow = 4 * Int(size.width)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        let flipVertical = CGAffineTransform(
            a: 1, b: 0, c: 0, d: -1, tx: 0, ty: ctxRect.size.height
        )
        ctx!.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0);
        ctx?.concatenate(flipVertical)
        #if os(iOS)
            var attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: Color.black] as [String : Any]
        #elseif os(OSX)
            var attributes: [AnyHashable: Any] = [kCTFontAttributeName as AnyHashable: font, kCTForegroundColorAttributeName as AnyHashable: NSColor.black.cgColor]
        #endif


        ctx?.setFillColor(bgColor.cgColor)
        ctx?.fill(ctxRect)


        let height = data.count
        let width = data[0].count
        let blockWidth = size.width / CGFloat(width)
        let blockHeight = size.height / CGFloat(height)

        for row in 0..<height {
            for col in 0..<width {
                let (string, color) = data[row][col]
                let rect = CGRect(x: blockWidth * CGFloat(col), y: blockHeight * CGFloat(row), width: blockWidth, height: blockHeight)
                configureAttributes(&attributes, color: color)
                let intermediate = CFAttributedStringCreate(nil, string as NSString, attributes as CFDictionary!)
                let line = CTLineCreateWithAttributedString(intermediate!)
                ctx?.textPosition = rect.origin
                CTLineDraw(line, ctx!)
            }
        }

        let cgImage = ctx?.makeImage()!
        return cgImage!.toImage()

    }

}

// MARK: Conversion
public extension ASCIIConverter {

    func convertImage(_ input: Image, completionHandler handler: @escaping ImageHandler) {
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
            let gridWidth = self.gridWidth(Int(input.size.width))
            let output = self.convertImage(input, withFont: self.font, bgColor: self.backgroundColor, columns: gridWidth, colorMode: self.colorMode)
            DispatchQueue.main.async { handler(output) }
        }
    }

    func convertToString(_ input: Image, completionHandler handler: @escaping StringHandler) {
        DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async(execute: {
            let output = self.convertToString(input)
            DispatchQueue.main.async(execute: { handler(output) })
        })
    }

    func convertImage(_ input: Image) -> Image {
        let gridWidth = self.gridWidth(Int(input.size.width))
        let output = convertImage(input, withFont: font, bgColor: backgroundColor, columns: gridWidth, colorMode: colorMode)
        return output
    }

    func convertImage(_ image: Image, withFont font: Font, bgColor: Color, columns: Int, colorMode: ColorMode) -> Image {
        let downscaled = downscaleImage(image, withFactor: columns)
        let pixelGrid = BlockGrid(image: downscaled)

        let result = pixelGrid.map { block -> (String, Color) in
            let mappedString = self.lut.lookup(block)!
            let color: Color
            if colorMode == .color {
                color = Color(red: CGFloat(block.r), green: CGFloat(block.g), blue: CGFloat(block.b), alpha: 1.0)
            } else if colorMode == .grayScale {
                color = Color(white: CGFloat(LuminanceLookupTable.luminance(block)), alpha: 1.0)
            } else {
                color = Color.black
            }
            return (mappedString, color)
        }
        var bgColor = bgColor
        if colorMode == .blackAndWhite {
            bgColor = .white
        }
        return stringsAndColorsToContext(result, size: image.size, bgColor: bgColor, font: font)

    }

    func convertToString(_ input: Image) -> String {
        let gridWidth = self.gridWidth(Int(input.size.width))
        let scaledImage = downscaleImage(input, withFactor: gridWidth)
        let pixelGrid = BlockGrid(image: scaledImage)
        var str = ""
        for row in 0..<pixelGrid.height {
            for col in 0..<pixelGrid.width {
                let block = pixelGrid.block(atRow: row, column: col)
                let outchar = lut.lookup(block)
                str += outchar! + " "
            }
            str += "\n"
        }
        return String(str)
    }
}
