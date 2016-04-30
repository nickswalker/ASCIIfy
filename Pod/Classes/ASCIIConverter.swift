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
#elseif os(iOS)
    import UIKit
    public typealias Font = UIFont
    public typealias Image = UIImage
    public typealias Color = UIColor
#endif

public typealias ImageHandler = ((Image) -> Void)?
public typealias StringHandler = ((String) -> Void)?

public class ASCIIConverter {
    var definition = ASCIILookUpTable()
    public var font = Font.systemFontOfSize(defaultFontSize)
    public var backgroundColor = Color.clearColor()
    var columns: Int?
    public var reversedLuminance = true
    public var colorMode = ColorMode.Color
    private func gridWidth(width: Int) -> Int {
        if columns ?? 0 <= 0 {
            return Int(CGFloat(width) / font.pointSize)
        } else {
            return Int(columns!)
        }
    }

    static let defaultFontSize: CGFloat = 10.0

    public enum ColorMode {
        case BlackAndWhite,
        GrayScale,
        Color
    }

    public init() {
    }

    public init(luminanceToStringMapping: [Double: String]) {
        definition = ASCIILookUpTable(luminanceToStringMapping: luminanceToStringMapping)
    }

    public init(definition: ASCIILookUpTable) {
        self.definition = definition
    }

    func isTransparent() -> Bool {
        return backgroundColor == Color.clearColor()
    }

    private func luminance(block: BlockGrid.Block) -> CGFloat {
        var result = 0.2126 * block.r + 0.7152 * block.g + 0.0722 * block.b
        if reversedLuminance {
            result = (1.0 - result)
        }
        return CGFloat(result)
    }

    #if os(iOS)
    private func configureAttributes(inout attributes: [String: NSObject], color: Color) {
        attributes[NSForegroundColorAttributeName] = color
    }

    #elseif os(OSX)
    private func configureAttributes(inout attributes: [NSObject: AnyObject], color: Color){
        attributes[kCTForegroundColorAttributeName] = color.CGColor
    }
    #endif

    private func stringsAndColorsToContext(data: [[(String, Color)]], size: CGSize, bgColor: Color, opaque: Bool) -> Image {
        // Setup background
        let ctxRect = CGRect(origin: CGPointZero, size: size)


        let bitsPerComponent = 8
        let bytesPerRow = 4 * Int(size.width)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Big.rawValue)
        let ctx = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        #if os(iOS)
            var attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: Color.blackColor()]
        #elseif os(OSX)
            let flipVertical = CGAffineTransformMake(
                1, 0, 0, -1, 0, ctxRect.size.height
            )
            CGContextConcatCTM(ctx, flipVertical)
            var attributes: [NSObject: AnyObject] = [kCTFontAttributeName: font, kCTForegroundColorAttributeName: NSColor.blackColor().CGColor]
        #endif

        if opaque {
            CGContextSetFillColorWithColor(ctx, bgColor.CGColor)
            CGContextFillRect(ctx, ctxRect)
        } else {
            CGContextClearRect(ctx, ctxRect)
        }

        let height = data.count
        let width = data[0].count
        let blockWidth = size.width / CGFloat(width)
        let blockHeight = size.height / CGFloat(height)

        for row in 0..<height {
            for col in 0..<width {
                let (string, color) = data[row][col]
                let rect = CGRect(x: blockWidth * CGFloat(col), y: blockHeight * CGFloat(row), width: blockWidth, height: blockHeight)
                configureAttributes(&attributes, color: color)
                let intermediate = CFAttributedStringCreate(nil, string as NSString, attributes)
                let line = CTLineCreateWithAttributedString(intermediate)
                CGContextSetTextPosition(ctx, rect.origin.x, rect.origin.y)
                CTLineDraw(line, ctx!)
            }
        }

        let cgImage = CGBitmapContextCreateImage(ctx)!
        return cgImage.toImage()

    }

}

// MARK: Conversion
public extension ASCIIConverter {

    func convertImage(input: Image, completionHandler handler: ImageHandler) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let gridWidth = self.gridWidth(Int(input.size.width))
            let output = self.convertImage(input, withFont: self.font, bgColor: self.backgroundColor, columns: gridWidth, reversed: self.reversedLuminance, colorMode: self.colorMode)
            dispatch_async(dispatch_get_main_queue()) { handler?(output) }
        }
    }

    func convertToString(input: Image, completionHandler handler: StringHandler) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let output = self.convertToString(input)
            dispatch_async(dispatch_get_main_queue(), { handler?(output) })
        })
    }

    func convertImage(input: Image) -> Image {
        let gridWidth = self.gridWidth(Int(input.size.width))
        let output = convertImage(input, withFont: font, bgColor: backgroundColor, columns: gridWidth, reversed: reversedLuminance, colorMode: colorMode)
        return output
    }

    func convertImage(image: Image, withFont font: Font, bgColor: Color, columns: Int, reversed: Bool, colorMode: ColorMode) -> Image {
        let opaque = !isTransparent()
        let downscaled = downscaleImage(image, withFactor: columns)
        let pixelGrid = BlockGrid(image: downscaled)

        let result = pixelGrid.map { block -> (String, Color) in
            let luminance = self.luminance(block)
            let mappedString = self.definition.stringForLuminance(Double(luminance))!
            let color: Color
            if colorMode == .Color {
                color = Color(red: CGFloat(block.r), green: CGFloat(block.g), blue: CGFloat(block.b), alpha: 1.0)
            } else if colorMode == .GrayScale {
                color = Color(white: luminance, alpha: 1.0)
            } else {
                color = Color.blackColor()
            }
            return (mappedString, color)
        }
        var bgColor = bgColor
        if colorMode == .BlackAndWhite {
            bgColor = .whiteColor()
        }
        return stringsAndColorsToContext(result, size: image.size, bgColor: bgColor, opaque: opaque)

    }

    func convertImageBlackAndWhite(image: Image, withFont font: Font, bgColor: Color, columns: Int, reversed: Bool) -> Image {
        let opaque = !isTransparent()
        let string = convertToString(image)

        let ctx: CGContext
        #if os(iOS)
            UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
            ctx = UIGraphicsGetCurrentContext()!
        #elseif os(OSX)
            ctx = NSGraphicsContext(bitmapImageRep: NSBitmapImageRep(CGImage: image.toCGImage))!.CGContext
        #endif
        // Setup background
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        if opaque {
            CGContextSetFillColorWithColor(ctx, bgColor.CGColor)
            CGContextFillRect(ctx, rect)
        } else {
            CGContextClearRect(ctx, rect)
        }

        let attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: Color.blackColor()]

        string.drawWithRect(rect, options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)

        let cgImage = CGBitmapContextCreateImage(ctx)!

        #if os(iOS)
            UIGraphicsEndImageContext()
        #endif
        return cgImage.toImage()
    }

    func convertToString(input: Image) -> String {
        let gridWidth = self.gridWidth(Int(input.size.width))
        let scaledImage = downscaleImage(input, withFactor: gridWidth)
        let pixelGrid = BlockGrid(image: scaledImage)
        let str = NSMutableString(string: "")
        for row in 0..<pixelGrid.height {
            for col in 0..<pixelGrid.width {
                let block = pixelGrid.block(atRow: row, column: col)
                let luminance = self.luminance(block)
                let ASCII = definition.stringForLuminance(Double(luminance))
                str.appendString(ASCII!)
                str.appendString(" ")
            }
            str.appendString("\n")
        }
        return String(str)
    }
}
