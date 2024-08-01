//
//  ContentView.swift
//  ScanOcr
//
//  Created by ddr on 26/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showScannerSheet = false
    @State private var texts: [ScanData] = []
    var body: some View {
        
//        VStack {
//            //makeScannerView()
//            Text("Hello, World!")
//        }
//        .background(Color.purple)
        NavigationView {
            VStack {
                // makeScannerView()
                if texts.count > 0 {
                    List {
                        ForEach(texts) { text in
                            NavigationLink(
                                destination: ScrollView{
                                    Text(text.content)
                                }, label: {
                                    Text(text.content).lineLimit(1)
                                }
                            )
                            
                        }
                    }
                }
                
            }
            .navigationTitle("Scan")
            .navigationBarItems(trailing:
                Button(action: {
                self.showScannerSheet = true
                //bodys
            }, label: {
                Image(systemName: "doc.text.viewfinder")
                .font(.title)
            })
            
            
                                
            .sheet(isPresented: $showScannerSheet, content: {
                makeScannerView()
                })
            )
            
        }
    }
    
    private func makeScannerView() -> ScanerView {
        
        
        ScanerView(completion: { textPerPage in
            if let outputText = textPerPage?.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines) {
                
                let newScanData = ScanData(content: outputText)
                self.texts = [newScanData]
                
            }
          self.showScannerSheet = false
        })
        
    }
   
}

#Preview {
    ContentView()
}




struct DetailsView: View {
    var body: some View {
        NavigationView {
            VStack {
                
            }
        }
    }
}
