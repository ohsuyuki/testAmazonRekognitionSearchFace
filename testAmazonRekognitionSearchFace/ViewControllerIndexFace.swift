//
//  ViewControllerIndexFace.swift
//  testAmazonRekognitionSearchFace
//
//  Created by osu on 2018/02/15.
//  Copyright © 2018 osu. All rights reserved.
//

import UIKit
import AWSRekognition

class ViewControllerIndexFace: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!

    @IBAction func selectImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerView = UIImagePickerController()
            pickerView.sourceType = .photoLibrary
            pickerView.delegate = self
            present(pickerView, animated: true)
        }
    }

    @IBAction func indexFace(_ sender: Any) {
        guard let image = imageView.image, let externalImageId = textField.text else {
            return
        }

        indexFaceAmazonRekognition(image, externalImageId: externalImageId)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        imageView.image = image
        dismiss(animated: true)
    }

    func indexFaceAmazonRekognition(_ image: UIImage, externalImageId: String) {
        let imgRekognition = AWSRekognitionImage()!
        imgRekognition.bytes = UIImageJPEGRepresentation(image, 0)
        
        let request = AWSRekognitionIndexFacesRequest()!
        request.collectionId = Key.collectionId
        request.image = imgRekognition
        request.externalImageId = externalImageId
        
        AWSRekognition.default().indexFaces(request) { (response, error) in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            guard let response = response else {
                print("response is nil")
                return
            }
            print(response)
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindViewController", sender: nil)
            }
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
