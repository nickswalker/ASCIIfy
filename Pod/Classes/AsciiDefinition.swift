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
import Foundation

public class AsciiDefinition {
    private let metrics: [Metric]
    struct Metric {
        let ascii: String
        let luminance: Double
        func description() -> String {
            return "ascii: \(self.ascii) luminance: \(self.luminance) "
        }
    }

    static let defaultMapping = [1.0: " ", 0.95: "`", 0.92: ".", 0.9: ",", 0.8: "-", 0.75: "~", 0.7: "+", 0.65: "<", 0.6: ">", 0.55: "o", 0.5: "=", 0.35: "*", 0.3: "%", 0.1: "X", 0.0: "@"]

    convenience init() {
        self.init(luminanceToStringMapping: AsciiDefinition.defaultMapping)
    }


    init(luminanceToStringMapping: [Double: String]) {
        metrics = AsciiDefinition.buildDataFromMapping(luminanceToStringMapping)
    }

    func stringForLuminance(luminance: Double) -> String? {
        let deltas = metrics.map{($0, abs($0.luminance - luminance))}
        let closest = deltas.minElement{$0.1 < $1.1}
        return closest?.0.ascii
    }

    private static func buildDataFromMapping(stringToLumMapping: [Double: String]) -> [Metric] {
        var pairs = stringToLumMapping.map{($0,$1)}
        pairs.sortInPlace{$0.1 < $1.1}
        return pairs.map{Metric(ascii: $0.1,luminance: $0.0)}
    }

    func logDefinition() {
        for m in metrics {
            print("\(m)")
        }
    }
}

