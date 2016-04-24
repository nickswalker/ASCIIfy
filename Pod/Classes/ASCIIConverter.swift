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
}


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

    func convertImage(image: Image, withFont font: Font, bgColor: Color, columns: Int?, reversed: Bool, colorMode: ColorMode) -> Image {
        if colorMode == .BlackAndWhite {
            return convertImageBlackAndWhite(image, withFont: font, bgColor: bgColor, columns: columns, reversed: reversed)
        }
        let opaque = !isTransparent()
        let downscaled = downscaleImage(image, withFactor: gridWidth(Int(image.size.width)))
        let pixelGrid = pixelGridForImage(downscaled)

        let ctx: CGContext
        #if os(iOS)
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
            ctx = UIGraphicsGetCurrentContext()!
        #elseif os(OSX)
            ctx = NSGraphicsContext(bitmapImageRep: NSBitmapImageRep(CGImage: image.toCGImage))!.CGContext
        #endif
        // Setup background
        let ctxRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        if opaque {
            CGContextSetFillColorWithColor(ctx, bgColor.CGColor)
            CGContextFillRect(ctx, ctxRect)
        } else {
            CGContextClearRect(ctx, ctxRect)
        }

        let blockWidth = image.size.width / CGFloat(pixelGrid.width)
        let blockHeight = image.size.height / CGFloat(pixelGrid.height)
        var attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: Color.blackColor()]
        for row in 0..<pixelGrid.height {
            for col in 0..<pixelGrid.width {
                let block = pixelGrid.block(atRow: row, column: col)
                let luminance = self.luminance(block)
                let ASCIIResult = definition.stringForLuminance(Double(luminance))!
                let rect = CGRect(x: blockWidth * CGFloat(col), y: blockHeight * CGFloat(row), width: blockWidth, height: blockHeight)

                if colorMode == .Color {
                    let color = Color(red: CGFloat(block.r), green: CGFloat(block.g), blue: CGFloat(block.b), alpha: 1.0)
                     attributes[NSForegroundColorAttributeName] = color
                } else if colorMode == .GrayScale {
                    let color = Color(white: luminance, alpha: 1.0)
                    attributes[NSForegroundColorAttributeName] = color
                }
                ASCIIResult.drawWithRect(rect, options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
            }
        }

        #if os(iOS)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        #elseif os(OSX)
            let cgImage = CGBitmapContextCreateImage(ctx)!
            return cgImage.toImage()
        #endif
    }

    func convertImageBlackAndWhite(image: Image, withFont font: Font, bgColor: Color, columns: Int?, reversed: Bool) -> Image {
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
        let pixelGrid = pixelGridForImage(scaledImage)
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

    /**
     Converts an image into pixel addressable format

     - parameter image: image to convert

     - returns: grid of pixels
     */
    private func pixelGridForImage(image: CGImage) -> BlockGrid {
        let width = CGImageGetWidth(image)
        let height = CGImageGetHeight(image)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = UnsafeMutablePointer<UInt8>(malloc(height * width * 4))
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Big.rawValue)
        let context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: width, height: height), image)
        let grid = BlockGrid(width: width, height: height)
        for row in 0..<height {
            for col in 0..<width {
                let byteIndex = (bytesPerRow * row) + col * bytesPerPixel
                let r = Double(rawData[byteIndex]) / 255.0
                let g = Double(rawData[byteIndex + 1]) / 255.0
                let b = Double(rawData[byteIndex + 2]) / 255.0
                let a = Double(rawData[byteIndex + 3]) / 255.0
                grid.copy(BlockGrid.Block(r: r, g: g, b: b, a: a), toRow: row, column: col)
            }
        }
        free(rawData)
        return grid
    }
}
