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
import Alamofire
import SwiftyJSON

enum ImageClassificationError: Error {
    enum Image: Error {
        case get
        case uiToCiConversion
    }
}

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    let imagePicker = UIImagePickerController()
    let flowerClassifier = FlowerClassifier()
    @IBOutlet weak var imageView: UIImageView!
    
    //set observation properties and method
    let wikiAPI = WikiAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let infoKey = UIImagePickerController.InfoKey.editedImage
        do{
            guard let userPickedimage = info[infoKey] as? UIImage else {
                throw ImageClassificationError.Image.get
            }
            imageView.image = userPickedimage
            guard let ciImage = CIImage(image: userPickedimage) else {
                throw ImageClassificationError.Image.uiToCiConversion
            }
            
            try detect(ciImage)
            
        } catch ImageClassificationError.Image.get {
            fatalError("Could not take a picture from the camera")
        } catch ImageClassificationError.Image.uiToCiConversion {
            fatalError("Could not convert UIImage to CIImage")
        } catch {
            fatalError("Unexpected error: \(error)")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(_ image: CIImage) throws {
        let model = try VNCoreMLModel(for: flowerClassifier.model)
        let request = VNCoreMLRequest(model: model) { request, error in
            if let classification = request.results?.first as? VNClassificationObservation {
                let flowerName = classification.identifier.capitalized
                self.navigationItem.title = flowerName
                
                self.wikiAPI.flowerName = flowerName
                self.wikiAPI.getFlowerInfo{print($0)}
            } else {
                fatalError()
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

