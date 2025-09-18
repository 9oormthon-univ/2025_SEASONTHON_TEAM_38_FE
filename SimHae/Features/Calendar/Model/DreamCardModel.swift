//
//  DreamCardModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation

struct DateValue: Identifiable {
    var id: String = UUID().uuidString
    var day: Int
    var date: Date
}

struct DreamRowUI: Identifiable, Hashable {
    let id: String
    let title: String
    let content: String
    let emoji: String?
    let dreamDate: Date
    let createdAt: Date
}
