//
//  CameraView.swift
//  Resnet50
//
//  Created by yoshitaka on 2023/12/08.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    private let cameraManger = CameraManager()

    var body: some View {
        ZStack {
            CameraPreview(session: cameraManger.session)
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                    .padding()
            }
        }
    }
}
#Preview {
    CameraView()
}

class CameraManager: {
    internal let session = AVCaptureSession()

    init() {
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
            if session.canAddInput(input) {
                session.addInput(input)
            }

            let output = AVCaptureVideoDataOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            session.startRunning()
        } catch {
            print("error")
        }
    }
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
