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

import UIKit
import ASCIIfy

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var imagePicker: UIImagePickerController?
    private var inputImage: UIImage?
    private var outputImage: UIImage? {
        didSet(oldValue) {
            if displayingOutput {
                imageView.image = outputImage
            }
        }
    }
    private var colorMode: ASCIIConverter.ColorMode = .Color {
        didSet(oldValue) {
            processInput()
        }
    }
    private var displayingOutput = true {
        didSet(oldValue){
            if displayingOutput {
                imageView.image = outputImage
            } else {
                imageView.image = inputImage
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure demo image
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("flower", ofType: "jpg")!
        inputImage = UIImage(contentsOfFile: path)
        processInput()
        fontSizeLabel.text = "\(Int(fontSizeSlider.value))"
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        inputImage = info[UIImagePickerControllerEditedImage] as? UIImage
        imagePicker?.dismissViewControllerAnimated(true, completion: nil)
        processInput()
    }

    private func processInput() {
        let font = ASCIIConverter.defaultFont.fontWithSize(CGFloat(fontSizeSlider.value))
        activityIndicator.startAnimating()
        inputImage?.fy_asciiImageWith(font, colorMode: colorMode) { image in
            self.activityIndicator.stopAnimating()
            self.outputImage = image
        }

    }

    // MARK: Interaction

    @IBAction func pickNewImage(sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .PhotoLibrary
        self.imagePicker = picker
        presentViewController(picker, animated: true, completion: nil)
    }

    @IBAction func didShare(sender: UIBarButtonItem) {
        guard let outputImage = outputImage else {
            return
        }
        let controller = UIActivityViewController(activityItems: [outputImage], applicationActivities: nil)
        presentViewController(controller, animated: true, completion: nil)
    }

    @IBAction func didPressDown(sender: UIButton) {
        displayingOutput = false
    }

    @IBAction func didRelease(sender: UIButton) {
        displayingOutput = true
    }

    @IBAction func fontSizeChanged(sender: UISlider) {
        fontSizeLabel.text = "\(Int(fontSizeSlider.value))"
        processInput()
    }

    // MARK: Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "options" {
            let navController = (segue.destinationViewController as? UINavigationController)
            let optionsController = navController?.childViewControllers[0] as? OptionsController
            optionsController?.modeChangeHandler = { self.colorMode = $0}
            optionsController?.mode = colorMode
        }
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {

    }

}

