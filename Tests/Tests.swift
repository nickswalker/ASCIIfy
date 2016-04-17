import UIKit
import XCTest
import ASCIIfy

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicChecker() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let fileLocation = bundle.pathForResource("checker-2x2", ofType: "png")!
        let image = UIImage(contentsOfFile: fileLocation)!
        let converter = AsciiConverter()
        let result = converter.convertToString(image)

        XCTAssertEqual(result, "@   \n  @ \n")
    }
    
}
