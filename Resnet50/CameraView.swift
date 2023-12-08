//
//  CameraView.swift
//  Resnet50
//
//  Created by yoshitaka on 2023/12/08.
//

import SwiftUI
import AVFoundation
import Combine
import Vision
import CoreML

struct CameraView: View {
    @ObservedObject private var cameraManager = CameraManager()

    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)

            VStack {
                Spacer() // 画面上部を空ける
                Text(cameraManager.classificationLabel)
                    .font(.title) // フォントサイズを大きくする
                    .padding()
                    .background(Color.white.opacity(0.7)) // 背景色を設定
                    .foregroundColor(.black)
                    .cornerRadius(10) // 角を丸くする
                    .padding() // 余白を設定
            }
        }
    }
}

#Preview {
    CameraView()
}

class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    @Published var classificationLabel: String = ""
    internal let session = AVCaptureSession()
    private var lastInferenceTime = Date()

    override init() {
        super.init()
        checkCameraPermission()
        setupSession()
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("許可済み")
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("許可されました")
                }
            }
        default:
            print("許可されませんでした")
            break
        }
    }

    private func setupSession() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))

            DispatchQueue.main.async {
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }

                if self.session.canAddOutput(output) {
                    self.session.addOutput(output)
                }
            }

            // startRunningをバックグラウンドスレッドで実行
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        } catch {
            print("error")
        }
    }


    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(lastInferenceTime)

        if elapsedTime > 1.0 {
            lastInferenceTime = currentTime

            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            classifyImage(pixelBuffer: pixelBuffer)
        }
    }


    func classifyImage(pixelBuffer: CVPixelBuffer) {
        guard let model = try? VNCoreMLModel(for: Resnet50(configuration: MLModelConfiguration()).model) else { return }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else { return } // 最も確率が高い結果を取得

            let confidence = topResult.confidence * 100 // 確率をパーセンテージに変換
            let label = topResult.identifier
            let resultString = "\(label)の確率は\(String(format: "%.2f", confidence))%"

            DispatchQueue.main.async {
                self?.classificationLabel = resultString
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }

//    func classifyImage(pixelBuffer: CVPixelBuffer) {
//        guard let model = try? VNCoreMLModel(for: Resnet50(configuration: MLModelConfiguration()).model) else { return }
//
//        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
//            guard let results = request.results as? [VNClassificationObservation],
//                  let topResult = results.first else { return }
//
//            let confidence = topResult.confidence * 100 // 確率をパーセンテージに変換
//            let label = topResult.identifier
//            let resultString = "\(label)の確率は\(String(format: "%.2f", confidence))%"
//
//            DispatchQueue.main.async {
//                self?.classificationLabel = resultString
//            }
//        }
//
//        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
//        try? handler.perform([request])
//    }

}
struct CameraPreview: UIViewRepresentable {
    var session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
