//
//  DreamDetailDTO.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation

//디테일 뷰 모델에 있던거

struct DreamDetailDTO: Decodable {
    let dreamId: Int
    let dreamDate: String          // "yyyy-MM-dd"
    let createdAt: String          // ISO 8601
    let title: String
    let emoji: String
    let content: String
    let categoryName: String
    let categoryDescription: String
    let interpretation: String
    let suggestion: String
}



extension DreamDetailDTO {
    func toDomain() -> DreamDetail {
        // 날짜 파서
        let dayDF = DateFormatter()
        dayDF.calendar = .init(identifier: .gregorian)
        dayDF.locale   = .init(identifier: "en_US_POSIX")
        dayDF.dateFormat = "yyyy-MM-dd"
        
        let iso = ISO8601DateFormatter()
        
        return DreamDetail(
            id: String(dreamId),
            dreamDate: dayDF.date(from: dreamDate),
            createdAt: iso.date(from: createdAt),
            title: title,
            emoji: emoji,
            content: content,
            categoryName: categoryName,
            categoryDescription: categoryDescription,
            interpretation: interpretation,
            suggestion: suggestion
        )
    }
}
