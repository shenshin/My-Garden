//
//  ViewController.swift
//  MyGarden
//
//  Created by Алесь Шеншин on 28/01/2019.
//  Copyright © 2019 Shenshin. All rights reserved.
//

import UIKit
import CoreML
import Vision

enum ImageClassificationError: Error {
    case getUIImage
    case uIImageToCIImageConversion
}

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let imagePicker = UIImagePickerController()
    let flowerClassifier = FlowerClassifier()
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let infoKey = UIImagePickerController.InfoKey.editedImage
        do{
            guard let userPickedimage = info[infoKey] as? UIImage else {
                throw ImageClassificationError.getUIImage
            }
            imageView.image = userPickedimage
            guard let ciImage = CIImage(image: userPickedimage) else {
                throw ImageClassificationError.uIImageToCIImageConversion
            }
            
            try detect(ciImage)
            
        } catch ImageClassificationError.getUIImage {
            fatalError("Could not take a picture from the camera")
        } catch ImageClassificationError.uIImageToCIImageConversion {
            fatalError("Could not convert UIImage to CIImage")
        } catch {
            fatalError("Unexpected error: \(error)")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(_ image: CIImage) throws {
        let model = try VNCoreMLModel(for: flowerClassifier.model)
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation] {
                if let firstAnswer = results.first {
                    self.navigationItem.title = firstAnswer.identifier
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        try handler.perform([request])
    }

    @IBAction func tappedCameraButton(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = (sender.tag == 1) ? .photoLibrary : .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
}
