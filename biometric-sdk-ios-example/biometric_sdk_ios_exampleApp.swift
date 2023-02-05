//
//  biometric_sdk_ios_exampleApp.swift
//  biometric-sdk-ios-example
//
//  Created by Slava on 05.02.2023.
//

import SwiftUI
import BiometricSdk
import TensorFlowLiteC

@main
struct biometric_sdk_ios_exampleApp: App {
    init() {
        let config = BiometricSdkConfigBuilder()
            .withFace(extractor: FaceExtractProperties(),
                      encoder: FaceEncodeProperties(faceNetModel:
                                                        FaceNetModelConfiguration(
                                                            tfliteModelPath:"assets://facenet-default.tflite",
                                                            inputWidth:       160,
                                                            inputHeight:      160,
                                                            outputLength:                128
                                                        )
                                                   ),
                      matcher: FaceMatchProperties(threshold: 10.0))
            .build()
        BiometricSdkFactory()
            .configure(config: config)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
