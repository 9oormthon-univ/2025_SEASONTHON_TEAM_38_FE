//
//  DayDreamDTO.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation

struct DreamCardDTO: Decodable {
    let dreamId: Int
    let dreamDate: String
    let title: String
    let emoji: String?
    let content: String
    let category: String?
    let createdAt: String
}

/// DTO → UI 변환
extension DreamCardDTO {
    func toRowUI() throws -> DreamRowUI {
        guard let dDate = RealCalendarDreamService.dayDF.date(from: dreamDate) else {
            throw URLError(.cannotParseResponse)
        }
        let cAt = RealCalendarDreamService.iso8601Frac.date(from: createdAt) ?? dDate
        return DreamRowUI(
            id: String(dreamId),
            title: title,
            content: content,
            emoji: emoji,
            dreamDate: dDate,
            createdAt: cAt
        )
    }
}
