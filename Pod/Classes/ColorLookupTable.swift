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
import KDTree

extension Color: KDTreePoint {
    @nonobjc public static var dimensions: Int = 3
    public func kdDimension(_ dimension: Int) -> Double {
        let (r, g, b, _) = components()
        switch dimension {
        case 0:
            return Double(r)
        case 1:
            return Double(g)
        case 2:
            return Double(b)
        default:
            return 0.0
        }
    }

    public func squaredDistance(to otherPoint: Color) -> Double {
        let (r, g, b, a) = components()
        let (or, og, ob, oa) = otherPoint.components()
        return pow(r - or, 2) + pow(g - og, 2) + pow(b - ob, 2) + pow(a - oa, 2)
    }
    #if os(iOS)
    private func components() -> (Double, Double, Double, Double) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
    #elseif os(OSX)
    fileprivate func components() -> (Double, Double, Double, Double) {
        let color = usingColorSpaceName(NSCalibratedRGBColorSpace)!
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
    #endif
}


open class ColorLookupTable: LookupTable {
    // MARK: Properties
    fileprivate let tree: KDTree<KDTreeEntry<Color, String>>

    // MARK: Initialization
    public init() {
        let emojiList: [(String, Color)] = [("❤️", .red) , ("😡", .orange), ("🌞", .yellow), ("🍏", .green), ("🐌", .brown), ("🔵", .blue), ("👿", .purple), ("🌂", .magenta), ("🐇", .white)]
        let entries = emojiList.map{KDTreeEntry<Color, String>(key: $1, value: $0)}
        tree = KDTree(values: entries)
    }

    // MARK: LookupTable
    open func lookup(_ block: BlockGrid.Block) -> String? {
        let color = Color(colorLiteralRed: block.r, green: block.g, blue: block.b, alpha: block.a)
        let nearest = tree.nearest(toElement: KDTreeEntry<Color, String>(key: color, value: ""))
        return nearest?.value
    }

}
