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
#if os(iOS)
    import UIKit
#endif

public extension Image {

    func fy_asciiString() -> String {
        let converter = ASCIIConverter()
        return converter.convertToString(self)
    }

    func fy_asciiStringWith(_ handler: @escaping StringHandler) {
        let converter = ASCIIConverter()
        converter.convertToString(self) { handler($0) }
    }
    
    func fy_asciiImage(_ font: Font = ASCIIConverter.defaultFont) -> Image {
        let converter = ASCIIConverter()
        converter.font = font
        return converter.convertImage(self)
    }

    func fy_asciiImage(_ font: Font = ASCIIConverter.defaultFont, completionHandler handler: @escaping ImageHandler) {
        let converter = ASCIIConverter()
        converter.font = font
        converter.convertImage(self) { handler($0)}
    }

    func fy_asciiImageWith(_ font: Font = ASCIIConverter.defaultFont, bgColor: Color = .black, columns: Int? = nil, invertLuminance: Bool = true, colorMode: ASCIIConverter.ColorMode = .color, completionHandler handler: @escaping ImageHandler) {
        let converter = ASCIIConverter()
        converter.font = font
        converter.backgroundColor = bgColor
        converter.columns = columns
        converter.colorMode = colorMode
        converter.convertImage(self) { handler($0) }
    }

}
