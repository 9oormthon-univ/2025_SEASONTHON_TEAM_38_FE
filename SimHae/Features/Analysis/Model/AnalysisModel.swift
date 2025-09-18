//
//  AnalysisModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation

// MARK: - Domain Model
struct AnalysisSection: Codable, Equatable {
    let title: String
    let content: String
}

struct UnconsciousAnalyzeSummary: Codable, Equatable {
    let title: String
    let suggestion: String
    let recentDreams: [String]
    let analysis: [AnalysisSection]
}

extension UnconsciousAnalyzeResponseDTO {
    func toDomain() -> UnconsciousAnalyzeSummary {
        .init(
            title: data.title,
            suggestion: data.suggestion,
            recentDreams: data.recentDreams,
            analysis: data.analysis.map { AnalysisSection(title: $0.title, content: $0.content)}
        )
    }
}
