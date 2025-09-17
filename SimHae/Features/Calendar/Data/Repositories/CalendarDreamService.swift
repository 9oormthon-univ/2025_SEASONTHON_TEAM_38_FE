//
//  DreamService.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation
import Combine

protocol CalendarDreamService {
    func fetchDreams(for date: Date) -> AnyPublisher<[DreamRowUI], Error>
    func fetchMonthEmojis(year: Int, month: Int) -> AnyPublisher<[String: String], Error>
    func searchDreams(keyword: String) -> AnyPublisher<[DreamRowUI], Error>
}

final class RealCalendarDreamService: CalendarDreamService {
    private let client = APIClient.shared
    
    // 재사용 가능한 포맷터(생성 비용 ↓)
    static let dayDF: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.locale = .init(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    // yyyy-MM
     static let ymDF: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.locale   = .init(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM"
        return f
    }()
    
     static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        return f
    }()
    
    func fetchDreams(for date: Date) -> AnyPublisher<[DreamRowUI], Error> {
            var comps = URLComponents(url: client.baseURL, resolvingAgainstBaseURL: false)!
            comps.path = "/dreams/day"
            comps.queryItems = [URLQueryItem(name: "dreamDate", value: Self.dayDF.string(from: date))]
            let url = comps.url!

            // ✅ APIClient로 요청 생성 → Authorization 자동
            let req = client.request(url, method: "GET", authorized: true)

            return client.run(Envelope<[DreamCardDTO]>.self, with: req)
                .tryMap { env in
                    guard (200...299).contains(env.status) else { throw URLError(.badServerResponse) }
                    return try env.data.map { try $0.toRowUI() }
                }
                .eraseToAnyPublisher()
        }
    
    func fetchMonthEmojis(year: Int, month: Int) -> AnyPublisher<[String: String], Error> {
            var comps = DateComponents()
            comps.calendar = .init(identifier: .gregorian)
            comps.year = year
            comps.month = month
            let baseDate = comps.calendar!.date(from: comps)!
            let ym = Self.ymDF.string(from: baseDate)

            var urlc = URLComponents(url: client.baseURL, resolvingAgainstBaseURL: false)!
            // 백엔드 스펙에 맞춰 경로/파라미터 사용 (예시는 dreamDate=yyyy-MM)
            urlc.path = "/dreams"
            urlc.queryItems = [URLQueryItem(name: "dreamDate", value: ym)]
            let req = client.request(urlc.url!, method: "GET", authorized: true)

            struct DayEmojiDTO: Decodable { let dreamDate: String; let emoji: String? }

            return client.run(Envelope<[DayEmojiDTO]>.self, with: req)
                .tryMap { env in
                    guard (200...299).contains(env.status) else { throw URLError(.badServerResponse) }
                    // 중복 키 생겨도 최초 값 유지
                    return env.data.reduce(into: [String: String]()) { acc, dto in
                        if acc[dto.dreamDate] == nil {
                            acc[dto.dreamDate] = dto.emoji ?? "🌙"
                        }
                    }
                }
                .eraseToAnyPublisher()
        }
    
    private func makeGET(_ url: URL) -> URLRequest {
        var r = URLRequest(url: url)
        r.httpMethod = "GET"
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        r.setValue(AnonymousId.getOrCreate(), forHTTPHeaderField: "X-Anonymous-Id")

        return r
    }
    
    // ISO8601 + fractional seconds 공용 포맷터
        static let iso8601Frac: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return f
        }()


    //날짜 없이 키워드로
    func searchDreams(keyword: String) -> AnyPublisher<[DreamRowUI], Error> {
            var urlc = URLComponents(url: client.baseURL, resolvingAgainstBaseURL: false)!
            urlc.path = "/dreams"
            urlc.queryItems = [URLQueryItem(name: "keyword", value: keyword)]

            let req = client.request(urlc.url!, method: "GET", authorized: true)

            return client.run(Envelope<[DreamCardDTO]>.self, with: req)
                .tryMap { env in
                    guard (200...299).contains(env.status) else { throw URLError(.badServerResponse) }
                    return try env.data.map { try $0.toRowUI() }
                }
                .eraseToAnyPublisher()
        }
}
