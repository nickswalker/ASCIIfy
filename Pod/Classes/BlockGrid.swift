//
//  Copyright for portions of ASCIIfy are held by Barış Koç, 2014 as part of
//  project BKAsciiImage and Amy Dyer, 2012 as part of project ASCII. All other copyright 
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

/* BlockGrid is a wrapper around a buffer of block_t objects, which represent individual "pixels" in the
 ASCII art. Each block_t is just a list of CGFloat components, which can be used directly by Quartz. */

class BlockGrid {
    let width: Int
    let height: Int
    private var grid: [[Block]]

    struct Block {
        let r: Double
        let g: Double
        let b: Double
        let a: Double
    }

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        grid = [[Block]](count: height, repeatedValue: [Block](count: width, repeatedValue: Block(r: 0.0, g: 0.0, b: 0.0, a: 0.0)))
    }

    func copy(block: Block, toRow row: Int, column: Int){
        grid[row][column] = block
    }

    func block(atRow row: Int, column: Int) -> Block {
        return grid[row][column]
    }
}