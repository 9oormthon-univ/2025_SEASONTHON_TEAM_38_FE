//
//  DreamSessionModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation

// 꿈 기록
struct DreamInput: Equatable {
    var content: String
    var date: Date // UI 표시에만 사용, 서버 전송 x
}

// 꿈 요약
struct DreamRestate: Equatable {
    let emoji: String
    let title: String
    let content: String
    let category: String
    let categoryDescription: String
}

// 꿈 해몽
struct DreamInterpretation: Equatable {
    let title: String
    let detail: String
}
