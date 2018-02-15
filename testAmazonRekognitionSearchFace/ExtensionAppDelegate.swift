//
//  ExtensionAppDelegate.swift
//  testAmazonRekognitionSearchFace
//
//  Created by osu on 2018/02/13.
//  Copyright © 2018 osu. All rights reserved.
//

import Foundation
import AWSCore

// for AWS
extension AppDelegate {

    func initAWS() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.APNortheast1, identityPoolId:"ap-northeast-1:849a8371-f46a-4d5b-833d-2a84292abaee")
        let configuration = AWSServiceConfiguration(region:.USWest2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }

}
