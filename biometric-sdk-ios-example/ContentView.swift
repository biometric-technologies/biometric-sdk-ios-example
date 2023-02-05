//
//  ContentView.swift
//  biometric-sdk-ios-example
//
//  Created by Slava on 05.02.2023.
//

import SwiftUI
import BiometricSdk

struct ContentView: View {
    @State private var presentAlert = false
    @State private var src: UIImage = UIImage.init(named: "img1")!
    @State private var dst: UIImage?
    @State private var status: String = "Loading.."
    @State private var alertText: String = ""
    @State private var persons = Dictionary<String, [Data]>()
    
    var body: some View {
        VStack {
            Button(action: loadRandomPhoto, label: { Text("Load Random")})
                .clipShape(Capsule())
            Image(uiImage: src)
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 240)
            Button(action: detect, label: { Text("Dectect")})
                .clipShape(Capsule())
            Text(status)
                .padding([.top], 20.0)
            if(dst != nil) {
                Image(uiImage: dst!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 120)
            }
        }
        .alert(isPresented: $presentAlert, content: {
                    Alert(title: Text(alertText))
                })
        .padding()
        .task {
            loadDb()
        }
      
    }
    
    func loadRandomPhoto() -> Void {
        let randomInt = Int.random(in: 1..<5)
        src = UIImage(named: "img\(randomInt)")!
    }
    
    func detect() -> Void {
        status = "Searching..."
        let sdk = BiometricSdkFactory.shared.getInstance()
        let cgImagePtr = UnsafeMutableRawPointer( Unmanaged.passRetained(src.cgImage!).toOpaque())
        let converted = sdk.io().convert(image: cgImagePtr)
        let template = sdk.face().encoder().encode(
            sample: sdk.face().extractor().extract(sample: converted))
        let found = persons.first { (key: String, value: [Data]) in
            return sdk.face().matcher()
                .matchesAny(sample1: template, samples: value)
        }
        status = ""
        alertText = found?.key ?? "Unknown"
        presentAlert = true
    }
    
    func loadDb() -> Void {
        try? _loadFolder(path: "sheldon")
        try? _loadFolder(path: "howard")
        alertText = "Db initialized"
        presentAlert = true
        status = ""
    }
    
     func _loadFolder(path: String) throws {
        let sdk = BiometricSdkFactory.shared.getInstance()
        let filesPath = Bundle.main.resourcePath! + "/\(path)/"
        let files = try FileManager.default.contentsOfDirectory(atPath: filesPath)
        var result: [Data] = []
        for file in files {
            let uiImg = UIImage(contentsOfFile: filesPath + file)!
            var cgImagePtr = UnsafeMutableRawPointer( Unmanaged.passRetained(uiImg.cgImage!).toOpaque())
            let converted = sdk.io().convert(image: cgImagePtr)
            let template = sdk.face().encoder().encode(sample: converted)
            result.append(template)
        }
        persons[path] = result
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
