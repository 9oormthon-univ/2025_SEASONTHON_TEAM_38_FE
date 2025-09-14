//
//  DreamDetailModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation

// 앱에서 사용할 도메인 모델
struct DreamDetail: Equatable {
    let id: String
    let dreamDate: Date?
    let createdAt: Date?
    let title: String
    let emoji: String
    let content: String
    let categoryName: String
    let categoryDescription: String
    let interpretation: String
    let suggestion: String
}
