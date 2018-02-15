//
//  ViewController.swift
//  testAmazonRekognitionSearchFace
//
//  Created by osu on 2018/02/13.
//  Copyright © 2018 osu. All rights reserved.
//

import UIKit
import AVFoundation
import AWSRekognition

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewTrg: UIImageView!
    
    @IBAction func registerFace(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerView = UIImagePickerController()
            pickerView.sourceType = .photoLibrary
            pickerView.delegate = self
            present(pickerView, animated: true)
        }
    }

    private var sessionInstance: FactorySessionInstance? = nil
    private let storeImage = Store<UIImage>()
    private var imageViewBounds: CGRect!
    private let queueImageProcess = DispatchQueue(label: "imageProcess")
    private var viewRects: [UIView] = []

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        indexFace(image)
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let result = FactorySession.create()
        guard case Result<FactorySessionInstance, FactorySessionError>.success(let instance) = result else {
            return
        }

        sessionInstance = instance
        instance.output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "dscbsryzry"))
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let session = self.sessionInstance?.session else {
            return
        }
        session.startRunning()

        imageViewBounds = CGRect(origin: imageView.bounds.origin, size: imageView.bounds.size)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let image = sampleBuffer.toImage() else {
            return
        }

        let rects = ImageProcessor.detectFaces(image, ratioWidth: imageViewBounds.width / image.size.width, ratioHeight: imageViewBounds.height / image.size.height)
        
        DispatchQueue.main.sync {
            imageView.image = image
            cleanRects()
            if rects.count > 0 {
                drawRects(rects)
            }
        }
        
        guard rects.count > 0 else {
            return
        }
        
        guard storeImage.get() == nil else {
            return
        }
        
        storeImage.set(image)
        queueImageProcess.async {
            self.searchFace()
        }
    }

    private func searchFace() {
        guard let image = storeImage.get() else {
            return
        }

        #if false
        let trgImgRekognition = AWSRekognitionImage()!
        trgImgRekognition.bytes = UIImageJPEGRepresentation(image, 0)
        
        let request = AWSRekognitionCompareFacesRequest()!
        request.sourceImage = srcImgRekognition
        request.targetImage = trgImgRekognition
        
        print("compareFaces")
        
        AWSRekognition.default().compareFaces(request) { (response, error) in
            defer {
                self.storeImage.set(nil)
                DispatchQueue.main.sync {
                    self.imageViewTrg.image = image
                }
            }
            
            print("compareFaces finish")
            
            guard error == nil else {
                print("compareFaces error")
                DispatchQueue.main.sync {
                    self.labelError.text = error?.localizedDescription
                    self.labelSimilarity.text = "unmatch..."
                }
                return
            }
            
            if let response = response {
                print("compareFaces complete")
                var similarity: String = "unmatch..."
                if let faceMathes = response.faceMatches {
                    for faceMatch in faceMathes {
                        similarity = "\(faceMatch.similarity)"
                    }
                }
                
                DispatchQueue.main.sync {
                    self.labelSimilarity.text = similarity
                    self.labelError.text = "no error"
                }
            }
        }
        #else
            let imgRekognition = AWSRekognitionImage()!
            imgRekognition.bytes = UIImageJPEGRepresentation(image, 0)
            
            let request = AWSRekognitionSearchFacesByImageRequest()!
            request.collectionId = "testRekognitionSearchFace"
            request.image = imgRekognition
            
            AWSRekognition.default().searchFaces(byImage: request) { (response, error) in
                defer {
                    self.storeImage.set(nil)
                    DispatchQueue.main.sync {
                        self.imageViewTrg.image = image
                    }
                }
                
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
        #endif
    }

    private func drawRects(_ rects: [CGRect]) {
        for rect in rects {
            let point = imageView.convert(rect.origin, to: view)
            let frame = CGRect(origin: point, size: CGSize(width: rect.width, height: rect.height))
            let viewRect = UIView(frame: frame)
            viewRect.layer.borderColor = #colorLiteral(red: 1, green: 0.9490688443, blue: 0, alpha: 1)
            viewRect.layer.borderWidth = 5
            view.addSubview(viewRect)
            viewRects.append(viewRect)
        }
    }

    private func cleanRects() {
        for viewRect in viewRects {
            viewRect.removeFromSuperview()
        }
        viewRects.removeAll()
    }

}

