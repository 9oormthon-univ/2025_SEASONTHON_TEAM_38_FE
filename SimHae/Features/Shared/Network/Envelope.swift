//
//  Envelope.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import Foundation

struct Envelope<T: Decodable>: Decodable {
    let status: Int
    let message: String
    let data: T
}

// 에러 바디 파싱용(400일 때)
struct ErrorEnvelope: Decodable {
    let status: Int
    let message: String
}
