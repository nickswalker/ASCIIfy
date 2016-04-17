//
//  ViewController.swift
//  ASCIIfy
//
//  Created by Nick Walker on 04/17/2016.
//  Copyright (c) 2016 Nick Walker. All rights reserved.
//

import UIKit
import ASCIIfy

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickImage: UIButton!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var fontSizeLabel: UILabel!

    private var imagePicker: UIImagePickerController?
    private var inputImage: UIImage?
    private var outputImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pickNewImage(sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
        self.imagePicker = picker
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        inputImage = info[UIImagePickerControllerEditedImage] as? UIImage
        imagePicker?.dismissViewControllerAnimated(true, completion: nil)
        outputImage = inputImage?.bk_asciiImage()
        imageView.image = outputImage

    }

    @IBAction func didPressDown(sender: UIButton) {
        imageView.image = inputImage
    }

    @IBAction func didRelease(sender: UIButton) {
        imageView.image = outputImage
    }

    @IBAction func fontSizeChanged(sender: UISlider) {
        outputImage = inputImage?.bk_asciiImageWithFont(UIFont.systemFontOfSize(CGFloat(sender.value)))
        imageView.image = outputImage
    }
}

