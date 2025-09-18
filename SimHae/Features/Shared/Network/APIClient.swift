//
//  APIClient.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import Foundation
import Combine

private enum HTTPError: Error {
    case unauthorized            // 401
    case badStatus(Int)          // 4xx/5xx etc
}

final class APIClient {
    static let shared = APIClient()
    private init() {}
    
    let baseURL = URL(string: "https://www.simhae.o-r.kr")!
    private let session = URLSession(configuration: .default)
    
    // MARK: - Request Builder
    func request(_ url: URL,
                 method: String = "GET",
                 body: Encodable? = nil,
                 authorized: Bool = true) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if authorized, let token = TokenStore.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            req.httpBody = try? JSONEncoder().encode(AnyEncodable(body))
        }
#if DEBUG
        print("➡️ Request to:", url.absoluteString)
        print("Method:", method)
        print("Headers:", req.allHTTPHeaderFields ?? [:])
        if let body = req.httpBody, let json = String(data: body, encoding: .utf8) {
            print("Body:", json)
        }
#endif
        NetworkLogger.logRequest(req)
        
        return req
    }
    
    // MARK: - Run + 자동 Refresh
    func run<T: Decodable>(_ type: T.Type, with req: URLRequest) -> AnyPublisher<T, Error> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // 1) 실행 함수 (지역 함수) — Failure를 Error로 올려두면 추론 더 안전
        func execute(_ request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
            session.dataTaskPublisher(for: request)
                .mapError { $0 as Error }               // ← URLError -> Error
                .eraseToAnyPublisher()
        }
        
        return execute(req)
        // 1차 응답 검사
            .tryMap { output -> Data in
                guard let http = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                let code = http.statusCode
                if code == 401 { throw HTTPError.unauthorized }
                guard (200...299).contains(code) else { throw HTTPError.badStatus(code) }
                return output.data
            }
        // 401 이면 refresh → 원요청 재시도
            .catch { [weak self] error -> AnyPublisher<Data, Error> in
                guard let self = self else {
                    return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
                }
                guard case HTTPError.unauthorized = error else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                return self.refreshAccessToken()
                    .flatMap { _ in execute(self.rebuildAuthorizedRequest(from: req)) }
                    .tryMap { output -> Data in
                        guard let http = output.response as? HTTPURLResponse else {
                            throw URLError(.badServerResponse)
                        }
                        let code = http.statusCode
                        guard (200...299).contains(code) else { throw HTTPError.badStatus(code) }
                        return output.data
                    }
                    .eraseToAnyPublisher()
            }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    private func rebuildAuthorizedRequest(from req: URLRequest) -> URLRequest {
        var new = req
        if let token = TokenStore.accessToken {
            new.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return new
    }
    
    // MARK: - Refresh
    private func refreshAccessToken() -> AnyPublisher<Void, Error> {
        guard let refreshToken = TokenStore.refreshToken else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        
        let req = request("/auth/refresh", method: "POST",
                          body: ["refreshToken": refreshToken],
                          authorized: false)
        
        struct RefreshResponse: Decodable {
            let accessToken: String
            let refreshToken: String
        }
        return run(Envelope<RefreshResponse>.self, with: req)
            .tryMap { env in
                guard (200...299).contains(env.status) else {
                    throw URLError(.badServerResponse)
                }
                TokenStore.accessToken  = env.data.accessToken
                TokenStore.refreshToken = env.data.refreshToken
                return ()
            }
            .eraseToAnyPublisher()
    }
}

/// Encodable를 타입지정 없이 넘기기 위한 래퍼
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init(_ wrapped: Encodable) { self.encodeFunc = wrapped.encode }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}

extension APIClient {
    func request(_ path: String,
                 method: String = "GET",
                 body: Encodable? = nil,
                 authorized: Bool = true) -> URLRequest {
        let clean = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let url = baseURL.appendingPathComponent(clean)
        return request(url, method: method, body: body, authorized: authorized)
    }
}
