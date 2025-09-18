//
//  SearchService.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation
import Combine

// MARK: - Repository Protocol

protocol SearchRepositoryProtocol {
    func search(keyword: String, completion: @escaping (Result<[DreamRowUI], Error>) -> Void)
}

// MARK: - API Repository 구현

final class APISearchRepository: SearchRepositoryProtocol {
    private let api = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    
    func search(keyword: String, completion: @escaping (Result<[DreamRowUI], Error>) -> Void) {
           var comps = URLComponents(url: api.baseURL.appendingPathComponent("/dreams"), resolvingAgainstBaseURL: false)!
           comps.queryItems = [URLQueryItem(name: "keyword", value: keyword)]
           let req = URLRequest(url: comps.url!)

           api.run(Envelope<[DreamCardDTO]>.self, with: req)
               .tryMap { env -> [DreamRowUI] in
                   guard (200...299).contains(env.status) else { throw URLError(.badServerResponse) }
                   return try env.data.map { try $0.toRowUI() }   // ← 공통 매핑 사용
               }
               .receive(on: DispatchQueue.main)
               .sink { completionEvent in
                   if case .failure(let err) = completionEvent { completion(.failure(err)) }
               } receiveValue: { rows in
                   completion(.success(rows))
               }
               .store(in: &cancellables)
       }
}
