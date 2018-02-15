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

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewTrg: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    @IBAction func unwindViewController(segue: UIStoryboardSegue) {}
    
    private var sessionInstance: FactorySessionInstance? = nil
    private let storeImage = Store<UIImage>()
    private var imageViewBounds: CGRect!
    private let queueImageProcess = DispatchQueue(label: "imageProcess")
    private var viewRects: [UIView] = []

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

    override func viewWillDisappear(_ animated: Bool) {
        guard let session = self.sessionInstance?.session else {
            return
        }
        session.stopRunning()
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

        let imgRekognition = AWSRekognitionImage()!
        imgRekognition.bytes = UIImageJPEGRepresentation(image, 0)
        
        let request = AWSRekognitionSearchFacesByImageRequest()!
        request.collectionId = Key.collectionId
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

            guard let faceMatches = response.faceMatches else {
                return
            }

            var labelText = ""
            var count = 0
            for match in faceMatches {
                guard let face = match.face else {
                    continue
                }
                if labelText.isEmpty == false {
                    labelText += "\n"
                }

                var name = "unknown"
                var confidence: NSNumber = -1
                if let tmpName = face.externalImageId {
                    name = tmpName
                }
                if let tmpConfidence = face.confidence {
                    confidence = tmpConfidence
                }
                labelText += "\(name) (\(confidence))"
                count += 1
            }

            DispatchQueue.main.async {
                self.label.numberOfLines = count
                self.label.text = labelText
            }
        }
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

