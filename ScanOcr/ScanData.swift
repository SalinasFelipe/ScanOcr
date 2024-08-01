//
//  ScanData.swift
//  ScanOcr
//
//  Created by ddr on 26/06/24.
//

import Foundation

struct ScanData: Identifiable {
    var id = UUID()
    let content: String
    
    init(content: String) {
        self.content = content
    }
}
