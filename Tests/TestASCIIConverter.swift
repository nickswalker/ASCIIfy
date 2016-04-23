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

import XCTest
import ASCIIfy

class TestASCIIConverter: XCTestCase {
    var basicChecker: Image!
    var largeChecker: Image!
    var asymmetricChecker: Image!
    override func setUp() {
        super.setUp()
        let bundle = NSBundle(forClass: self.dynamicType)

        basicChecker = {
            let fileLocation = bundle.pathForResource("checker-2", ofType: "png")!
            let image = Image(contentsOfFile: fileLocation)!
            return image
        }()
        largeChecker = {
            let fileLocation = bundle.pathForResource("checker-1024", ofType: "png")!
            let image = Image(contentsOfFile: fileLocation)!
            return image
        }()
        asymmetricChecker = {
            let fileLocation = bundle.pathForResource("asymmetric-checker-2", ofType: "png")!
            let image = Image(contentsOfFile: fileLocation)!
            return image
            }()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicChecker() {
        let converter = ASCIIConverter()
        converter.reversedLuminance = true
        let result = converter.convertToString(basicChecker)
        XCTAssertEqual(result, "@   \n  @ \n")
    }

    func testBasicCheckerInverse() {
        let converter = ASCIIConverter()
        converter.reversedLuminance = false
        let result = converter.convertToString(basicChecker)
        XCTAssertEqual(result, "  @ \n@   \n")
    }

    func testThatImageOrientationIsNotChanged() {
        let converter = ASCIIConverter()
        converter.reversedLuminance = false
        let result = converter.convertToString(asymmetricChecker)
        XCTAssertEqual(result, "  @ \n<   \n")
    }

    func testStringConversionPerformance() {
        let converter = ASCIIConverter()
        measureBlock {
            let result = converter.convertImage(self.largeChecker)
            XCTAssertEqual(result.size, self.largeChecker.size)
        }

    }
    
}
