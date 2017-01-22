# ASCIIfy

[![CI Status](http://img.shields.io/travis/nickswalker/ASCIIfy.svg?style=flat)](https://travis-ci.org/nickswalker/ASCIIfy)
[![Version](https://img.shields.io/cocoapods/v/ASCIIfy.svg?style=flat)](http://cocoapods.org/pods/ASCIIfy)
[![License](https://img.shields.io/cocoapods/l/ASCIIfy.svg?style=flat)](http://cocoapods.org/pods/ASCIIfy)
[![Platform](https://img.shields.io/cocoapods/p/ASCIIfy.svg?style=flat)](http://cocoapods.org/pods/ASCIIfy)

<img src="http://i.imgur.com/xDp2DCC.gif" width="300px" />

Turn images to ASCII art. UIImage and NSImage extensions included.

## Installation

ASCIIfy is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ASCIIfy"
```

## Usage 

You start by poking around in the included Playground. You can do a basic conversion with just a couple lines:

	let font = ASCIIConverter.defaultFont.withSize(24.0)
        let outputImage = inputImage?.fy_asciiImageWith(font, colorMode: .color)

<img src="http://i.imgur.com/xDp2DCC.gif" width="300px" />

Extensions are great. You can also build a reusable `ASCIIConverter` object to expose fine-grain controls:

	let colorConverter = ASCIIConverter(lut: ColorLookupTable())
	colorConverter.font = font
	colorConverter.backgroundColor = .black
	colorConverter.colorMode = .color
	colorConverter.columns = 20

	let colorResult = colorConverter.convertImage(flowerImage)


<img src="http://i.imgur.com/4hcpCZm.gif" width="300px" />

You can even define your own lookup table to control the characters that get used. Take a look at the ColorLookupTable to get started:

	let colorConverter = ASCIIConverter(lut: ColorLookupTable())
	colorConverter.font = ASCIIConverter.defaultFont.withSize(30.0)
	colorConverter.backgroundColor = .black
	colorConverter.columns = 30

	let colorConverterResult = colorConverter.convertImage(flowerImage)

<img src="http://i.imgur.com/aPNdFV3.gif" width="300px" />

To run the example iOS and macOS projects, clone the repo, and run `pod install` from the `Example` directory. 

## Author

ASCIIfy is a heavily modified fork of [BKAsciiImage](https://github.com/bkoc/BKAsciiImage).

## License

ASCIIfy is available under the MIT license. See the LICENSE file for more info.
