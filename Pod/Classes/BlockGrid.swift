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
import CoreGraphics

public func == (lhs: BlockGrid.Block, rhs: BlockGrid.Block) -> Bool {
    return lhs.a == rhs.a &&
        lhs.r == rhs.r &&
        lhs.g == rhs.g &&
        lhs.b == rhs.b
}

/* BlockGrid is a wrapper around a buffer of block_t objects, which represent individual "pixels" in the
 ASCII art. Each block_t is just a list of CGFloat components, which can be used directly by Quartz. */

open class BlockGrid {
    let width: Int
    let height: Int
    fileprivate var grid: [[Block]]

    /**
     *  Represents an RGBA value
     */
    public struct Block: Equatable {
        let r: Float
        let g: Float
        let b: Float
        let a: Float
    }

    /**
     Creates a grid with all values set to black

     - parameter width:  width of the grid
     - parameter height: height of the grid
     */
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        grid = [[Block]](repeating: [Block](repeating: Block(r: 0.0, g: 0.0, b: 0.0, a: 0.0), count: width), count: height)
    }

    convenience init(image: Image) {
        self.init(image: image.toCGImage)
    }

    /**
     Converts an image into pixel addressable format

     - parameter image: image to convert

     - returns: grid of pixels
     */
    convenience init(image: CGImage) {
        let width = image.width
        let height = image.height
        self.init(width: width, height: height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: height * width * 4)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        let context = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        for row in 0..<height {
            for col in 0..<width {
                let byteIndex = (bytesPerRow * row) + col * bytesPerPixel
                let r = Float(rawData[byteIndex]) / 255.0
                let g = Float(rawData[byteIndex + 1]) / 255.0
                let b = Float(rawData[byteIndex + 2]) / 255.0
                let a = Float(rawData[byteIndex + 3]) / 255.0
                grid[row][col] = BlockGrid.Block(r: r, g: g, b: b, a: a)
            }
        }
        free(rawData)
    }

    func block(atRow row: Int, column: Int) -> Block {
        return grid[row][column]
    }
}

// MARK: Functional helpers
extension BlockGrid {
    /**
     Create a 2D array by applying a transformation to each block in the grid

     - parameter transformation: closure to apply to each block

     - returns: 2D array of transformed values
     */
    func map<T>(_ transformation: (Block) -> T) -> [[T]] {
        var result = [[T]](repeating: [T](), count: grid.count)
        for row in 0..<height {
            for col in 0..<width {
                result[row].append(transformation(grid[row][col]))
            }
        }
        return result
    }

    /**
     Apply a transformation to each block in the grid.

     - parameter transformation: closure to apply to each block
     */
    func forEach(_ transformation: (Block) -> Block) {
        for row in 0..<height {
            for col in 0..<width {
                grid[row][col] = transformation(grid[row][col])
            }
        }

    }
}
