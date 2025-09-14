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
        // /dreams/day?dreamDate=yyyy-MM-dd
        var comps = URLComponents(url: client.baseURL, resolvingAgainstBaseURL: false)!
        comps.path = "/dreams/day"
        
        let dayString = Self.dayDF.string(from: date)
        comps.queryItems = [URLQueryItem(name: "dreamDate", value: dayString)]
        let url = comps.url!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(AnonymousId.getOrCreate(), forHTTPHeaderField: "X-Anonymous-Id")
        
        return URLSession.shared.dataTaskPublisher(for: req)
                    .map(\.data)
                    .decode(type: Envelope<[DreamCardDTO]>.self, decoder: JSONDecoder())
                    .tryMap { env in
                        guard (200...299).contains(env.status) else { throw URLError(.badServerResponse) }
                        return try env.data.map { try $0.toRowUI() }   // 공통 매핑
                    }
                    .eraseToAnyPublisher()
    }
    
    func fetchMonthEmojis(year: Int, month: Int) -> AnyPublisher<[String: String], Error> {
        // yyyy-MM 문자열
        var comps = DateComponents()
        comps.calendar = .init(identifier: .gregorian)
        comps.year = year
        comps.month = month
        let baseDate = comps.calendar!.date(from: comps)!
        let ym = Self.ymDF.string(from: baseDate)
        
        // /dreams/month?yearMonth=yyyy-MM
        var urlc = URLComponents(url: client.baseURL, resolvingAgainstBaseURL: false)!
        urlc.path = "/dreams"
        urlc.queryItems = [URLQueryItem(name: "dreamDate", value: ym)]
        
        var req = URLRequest(url: urlc.url!)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(AnonymousId.getOrCreate(), forHTTPHeaderField: "X-Anonymous-Id")
        
        print("➡️ [fetchMonthEmojis] GET", urlc.url!.absoluteString)
         
        struct DayEmojiDTO: Decodable
        { let dreamDate: String
            let emoji: String?
        }
        return client.run(Envelope<[DayEmojiDTO]>.self, with: req)
            .tryMap { env in
                guard (200...299).contains(env.status) else { throw URLError(.badServerResponse) }
                // 중복 키가 있어도 첫 번째 값만 유지
                       let dict = env.data.reduce(into: [String: String]()) { acc, dto in
                           if acc[dto.dreamDate] == nil {
                               acc[dto.dreamDate] = dto.emoji ?? "🌙"
                           }
                       }
                       return dict
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
            urlc.queryItems = [
                URLQueryItem(name: "keyword", value: keyword)
            ]

            var req = URLRequest(url: urlc.url!)
            req.httpMethod = "GET"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue(AnonymousId.getOrCreate(), forHTTPHeaderField: "X-Anonymous-Id")

            
            return client.run(Envelope<[DreamCardDTO]>.self, with: req)
                       .tryMap { env in
                           guard (200...299).contains(env.status) else { throw URLError(.badServerResponse) }
                           return try env.data.map { try $0.toRowUI() }   // 공통 매핑
                       }
                       .eraseToAnyPublisher()
        }
}
