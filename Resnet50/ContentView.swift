//
//  ContentView.swift
//  Resnet50
//
//  Created by yoshitaka on 2023/12/07.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {

    @State private var classificationLable = ""
    @State private var selectedImageName: String? = nil
    private let imageNames = ["elephant", "bird", "husky"]

    //    リクエストを作成
    private func createClassificationRequest() -> VNCoreMLRequest {
        do {
            let cofiguration = MLModelConfiguration()

            let model = try VNCoreMLModel(for: Resnet50(configuration: cofiguration).model)

            let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
                perfomClassification(request: request)
            })

            return request

        } catch {
            fatalError("modelが読み込めません")
        }
    }

    private func perfomClassification(request: VNRequest) {
        guard let results = request.results else {
            return
        }
        let classification = results as! [VNClassificationObservation]

        classificationLable = classification[0].identifier
    }

    // 実際に画像を分類する
    private func classifyImage(named imageName: String) {
        guard let image = UIImage(named: imageName),
              // 入力された画像の型をUIImageからCIImageに変換
              let ciImage = CIImage(image: image) else {
            fatalError("CIImageに変換できません")
        }

        // handlerを作る
        let handler = VNImageRequestHandler(ciImage: ciImage)

        // requestを作成
        let classificationRequest = createClassificationRequest()

        // handlerを実行する
        do {
            try handler.perform([classificationRequest])
        } catch {
            fatalError("画像分類に失敗しました")
        }
    }

    var body: some View {
        ZStack {
            CameraView()
        }
    }
}

#Preview {
    ContentView()
}
