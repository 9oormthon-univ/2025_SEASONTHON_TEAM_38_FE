//
//  AnalysisDTO.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation

// MARK: - DTO (서버 응답)

struct UnconsciousAnalyzeResponseDTO: Decodable {
    let status: Int
    let message: String
    let data: Payload
    
    struct Payload: Decodable {
        let title: String
        let suggestion: String
        let recentDreams: [String]
        let analysis: [AnalysisSectionDTO]
    }
    
    struct AnalysisSectionDTO: Decodable {
        let title: String
        let content: String
    }
}
