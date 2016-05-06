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
//  BlockGrid class and block struct are adapted from
//  https://github.com/oxling/iphone-ascii/blob/master/ASCII/BlockGrid.h
//

import Foundation

#if os(iOS)
    import UIKit
#endif

internal func downscaleImage(image: Image, withFactor scaleFactor: Int) -> CGImage {
    var scaleFactor = CGFloat(scaleFactor)
    if scaleFactor <= 1 {
        return image.toCGImage
    }
    if scaleFactor > min(image.size.height, image.size.width) {
        scaleFactor = min(image.size.height, image.size.width)
    }
    let cgImage = image.toCGImage
    let ratio = scaleFactor / image.size.width
    let size = CGSize(width: scaleFactor, height: ratio * image.size.height)
    let rect = CGRect(origin: CGPointZero, size: size)
    let bitsPerComponent = CGImageGetBitsPerComponent(cgImage)
    let bytesPerRow = CGImageGetBytesPerRow(cgImage)
    let colorSpace = CGImageGetColorSpace(cgImage)
    let bitmapInfo = CGImageGetBitmapInfo(cgImage)

    let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)

    CGContextSetInterpolationQuality(context, .High)

    CGContextDrawImage(context, rect, cgImage)

    let result = CGBitmapContextCreateImage(context)!
    assert(CGFloat(CGImageGetWidth(result)) == scaleFactor)
    return result
}


internal extension CGImage {
    func toImage() -> Image {
        #if os(OSX)
            let size = CGSize(width: CGImageGetWidth(self), height: CGImageGetHeight(self))
            return NSImage(CGImage: self, size: size)
        #elseif os(iOS)
            return UIImage(CGImage: self)
        #endif
    }
}

#if os(OSX)
internal extension NSImage {
    var toCGImage: CGImage {
            var rect = NSRect(origin: CGPointZero, size: self.size)
            return CGImageForProposedRect(&rect, context: nil, hints: nil)!
    }
}
#elseif os(iOS)
    typealias CoreGraphicsImage = CGImage
internal extension UIImage {
    var toCGImage: CoreGraphicsImage {
        return CGImage!
    }
}
#endif