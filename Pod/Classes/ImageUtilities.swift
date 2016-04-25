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
    let ratio = scaleFactor / image.size.width

    let size = CGSize(width: scaleFactor, height: ratio * image.size.height)
    let rect = CGRect(origin: CGPointZero, size: size)
    let ctx: CGContext
    #if os(iOS)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        ctx = UIGraphicsGetCurrentContext()!
        image.drawInRect(rect)
        return UIGraphicsGetImageFromCurrentImageContext().CGImage!
    #elseif os(OSX)
        ctx = NSGraphicsContext(bitmapImageRep: NSBitmapImageRep(CGImage: image.toCGImage))!.CGContext
        let cgImage = image.toCGImage
        CGContextDrawImage(ctx, rect, cgImage)
        let result = CGBitmapContextCreateImage(ctx)!
        return result
    #endif
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