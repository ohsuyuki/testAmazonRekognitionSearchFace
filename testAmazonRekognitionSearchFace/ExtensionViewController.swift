//
//  ExtensionViewController.swift
//  testAmazonRekognitionSearchFace
//
//  Created by osu on 2018/02/13.
//  Copyright © 2018 osu. All rights reserved.
//

import Foundation
import AWSRekognition

extension ViewController {

    func indexFace(_ image: UIImage) {
        let imgRekognition = AWSRekognitionImage()!
        imgRekognition.bytes = UIImageJPEGRepresentation(image, 0)

        let request = AWSRekognitionIndexFacesRequest()!
        request.collectionId = "testRekognitionSearchFace"
        request.image = imgRekognition

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
        }
    }

    func searchFace(_ image: UIImage) {
        let imgRekognition = AWSRekognitionImage()!
        imgRekognition.bytes = UIImageJPEGRepresentation(image, 0)
        
        let request = AWSRekognitionSearchFacesByImageRequest()!
        request.collectionId = "testRekognitionSearchFace"
        request.image = imgRekognition

        AWSRekognition.default().searchFaces(byImage: request) { (response, error) in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            guard let response = response else {
                print("response is nil")
                return
            }
            print(response)
        }
    }

}
