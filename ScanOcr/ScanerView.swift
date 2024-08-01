//
//  ScanerView.swift
//  ScanOcr
//
//  Created by ddr on 26/06/24.
//

import VisionKit
import Foundation
import SwiftUI

struct ScanerView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(completion: completionHandler)
    }
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    private let completionHandler: ([String]?) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        
    }
    
    init(completion: @escaping ([String]?) -> Void) {
        self.completionHandler = completion
    }
}

final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
    private let completionHandler: ([String]?) -> Void
    
    init(completion: @escaping ([String]?) -> Void) {
        self.completionHandler = completion
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let recongnizer = TextRecongnizer(cameraScan: scan)
        recongnizer.recognizeText(withCompletionHandler: completionHandler)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        completionHandler(nil)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        completionHandler(nil)
    }
    
}
