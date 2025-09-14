//
//  AnalysisModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation

// MARK: - Domain Model
struct UnconsciousAnalyzeSummary: Equatable {
    let title: String
    let analysis: String
    let suggestion: String
    let recentDreams: [String]
}

extension UnconsciousAnalyzeResponseDTO {
    func toDomain() -> UnconsciousAnalyzeSummary {
        .init(
            title: data.title,
            analysis: data.analysis,
            suggestion: data.suggestion,
            recentDreams: data.recentDreams
        )
    }
}

