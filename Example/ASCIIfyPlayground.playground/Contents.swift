import ASCIIfy

let flowerImage = #imageLiteral(resourceName: "flower.jpg")
let font = ASCIIConverter.defaultFont.withSize(24.0)
let result = flowerImage.fy_asciiImage(font)


let converter = ASCIIConverter(lut: LuminanceLookupTable())
converter.font = ASCIIConverter.defaultFont.withSize(96.0)
converter.backgroundColor = .black
converter.colorMode = .color
converter.columns = 40

let converterResult = converter.convertImage(flowerImage)

let colorConverter = ASCIIConverter(lut: ColorLookupTable())
colorConverter.font = ASCIIConverter.defaultFont.withSize(30.0)
colorConverter.backgroundColor = .black
colorConverter.columns = 30

let colorConverterResult = colorConverter.convertImage(flowerImage)
