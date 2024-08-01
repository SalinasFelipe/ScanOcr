//
//  TextRecongnizer.swift
//  ScanOcr
//
//  Created by ddr on 26/06/24.
//

import Foundation
import VisionKit
import Vision

final class TextRecongnizer {
    let cameraScan: VNDocumentCameraScan
    var dataTextScand: [String] = []
    var dataTextScand2: [(CGRect, String)] = []
    var coordinatesArray: [CGRect] = []
    var storedImagesAndRequest: (image: CGImage, request: VNRecognizeTextRequest)?
    var counter: Int = 0
    
    init(cameraScan: VNDocumentCameraScan) {
        self.cameraScan = cameraScan
    }
    
    
    func captureImage(imagesAndRequest: (image: CGImage, request: VNRecognizeTextRequest)) {
          self.storedImagesAndRequest = imagesAndRequest
          let (image, request) = imagesAndRequest

          request.recognitionLevel = .accurate
          request.revision = VNRecognizeTextRequestRevision3

          let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
          do {
              try handler.perform([request])
              if let observations = request.results {
                  self.coordinatesArray = observations.map { $0.boundingBox }
                  
                  let croppedImages = self.cropImages(from: image, with: self.coordinatesArray)
                  
                  for (index, croppedImage) in croppedImages.enumerated() {
                      self.recognizeTextTwoImage(in: croppedImage) { text in
                          // Guardar coordenadas y texto en dataTextScand2
                          let coordinate = self.coordinatesArray[index]
                          self.dataTextScand2.append((coordinate, text))
                          print("Coordenada: \(coordinate), Texto reconocido: \(text)")
                      }
                  }
              }
          } catch {
              print("Error al procesar la imagen: \(error)")
          }
      }

    // 2. Recorta imágenes usando coordenadas
    func cropImages(from image: CGImage, with coordinates: [CGRect]) -> [CGImage] {
        var croppedImages: [CGImage] = []
        
        for coordinate in coordinates {
            let boundingBox = coordinate
            let size = CGSize(width: boundingBox.width * CGFloat(image.width), height: boundingBox.height * CGFloat(image.height))
            let origin = CGPoint(x: boundingBox.minX * CGFloat(image.width), y: (1 - boundingBox.maxY) * CGFloat(image.height))
            
            let croppingRect = CGRect(origin: origin, size: size)
            
            if let croppedImage = image.cropping(to: croppingRect) {
                croppedImages.append(croppedImage)
            }
        }
        return croppedImages
    }

    // 3. Reconoce texto en una imagen dada
    func recognizeTextTwoImage(in image: CGImage, completionHandler: @escaping (String) -> Void) {
        let request = VNRecognizeTextRequest()
        request.customWords = ["custOm"]
        request.recognitionLevel = .accurate
        request.revision = VNRecognizeTextRequestRevision3

        let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        do {
            try handler.perform([request])
            guard let observations = request.results else {
                completionHandler("")
                return
            }
            
            let text = observations.compactMap { result in
                return result.topCandidates(1).first?.string
            }.joined(separator: " ")
            completionHandler(text)
        } catch {
            print("Error al reconocer el texto: \(error)")
            completionHandler("")
        }
    }

    // 4. Llama a la función recognizeText desde el método recognizeText con las imágenes recortadas
    private let queue = DispatchQueue(label: "scan-codes", qos: .default)
    func recognizeText(withCompletionHandler completionHandler: @escaping ([String]) -> Void) {
           queue.async {
               let images = (0..<self.cameraScan.pageCount).compactMap({
                   self.cameraScan.imageOfPage(at: $0).cgImage
               })
               let imagesAndRequest = images.map { (image: $0, request: VNRecognizeTextRequest()) }
               if let firstImageAndRequest = imagesAndRequest.first {
                   self.captureImage(imagesAndRequest: firstImageAndRequest)
               }
               
               var textPerPage: [String] = []
               
               for (image, request) in imagesAndRequest {
                   request.customWords = ["custOm"]
                   request.recognitionLevel = .accurate
                   request.revision = VNRecognizeTextRequestRevision3
                   
                   let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
                   do {
                       try handler.perform([request])
                       guard request.results != nil else {
                           textPerPage.append("")
                           continue
                       }
                       
                       // Aquí se asume que dataTextScand2 es una propiedad de la clase y ya ha sido llenada por captureImage
                        let text = self.dataTextScand2.map { $0.1 }.joined(separator: " ")
                        textPerPage.append(text)
                   } catch {
                       print("Error al reconocer texto: \(error)")
                       textPerPage.append("")
                   }
               }
               
               DispatchQueue.main.async {
                   completionHandler(textPerPage)
               }
           }
       }
}

                    // 1. guardar la imagen en una variable -> imagen que se toma
                    // 2. obtener una coordenada (guardar en una array)
                    // 3. sacar una imagen apartir de las coordenas que ya haya sacado
                    // 4. apartir de la imagen grande sacar una imagen pequena con las coordenadas especificas
                    // 5. que pase por esta funcion que se llama recognizeText


