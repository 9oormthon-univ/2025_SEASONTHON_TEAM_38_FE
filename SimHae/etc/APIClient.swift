//
//  APIClient.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import Foundation
import Combine

final class APIClient {
    static let shared = APIClient()
    private init() {}

    var baseURL = URL(string: "https://www.simhae.p-e.kr")!   // ✅ 실제 서버 도메인
    
    /// 공통 Request 생성
    func request(_ path: String,
                 method: String = "GET",
                 body: Encodable? = nil) -> URLRequest {
        var url = baseURL
        url.append(path: path)

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(AnonymousId.getOrCreate(), forHTTPHeaderField: "X-Anonymous-Id")

        if let body {
            req.httpBody = try? JSONEncoder().encode(AnyEncodable(body))
        }
        
        // ⭐️ 디버그 로그 출력
           //if DEBUG
           print("➡️ Request to:", url.absoluteString)
           print("Method:", method)
           print("Headers:", req.allHTTPHeaderFields ?? [:])
           if let body = req.httpBody,
              let json = String(data: body, encoding: .utf8) {
               print("Body:", json)
           }
           //endif
        return req
    }

    /// 응답 실행
    func run<T: Decodable>(_ type: T.Type, with request: URLRequest) -> AnyPublisher<T, Error> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601   // ✅ createdAt 같은 ISO 날짜 지원

        
        return URLSession.shared.dataTaskPublisher(for: request)
                    .tryMap { output -> Data in
                        let http = output.response as? HTTPURLResponse
                        let code = http?.statusCode ?? -1
                        let text = String(data: output.data, encoding: .utf8) ?? "<non-utf8 or empty>"
                        print("⬅️ Response \(code) from:", request.url?.absoluteString ?? "")
                        print("Raw body:", text)

                        // 바디가 비었으면 명확한 에러
                        if output.data.isEmpty {
                            throw URLError(.zeroByteResource) // “data is missing” 원인 파악 쉬움
                        }
                        // 4xx/5xx면 에러로 올림 (원문도 로그에 찍힘)
                        if !(200...299).contains(code) {
                            throw URLError(.badServerResponse)
                        }
                        return output.data
                    }
                    .decode(type: T.self, decoder: decoder)
                    .eraseToAnyPublisher()
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .map(\.data)
//            .decode(type: T.self, decoder: decoder)
//            .eraseToAnyPublisher()
    }
}

/// Encodable를 타입지정 없이 넘기기 위한 래퍼
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init(_ wrapped: Encodable) { self.encodeFunc = wrapped.encode }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}
