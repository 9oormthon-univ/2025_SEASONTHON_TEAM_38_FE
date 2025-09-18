//
//  DreamDetailService.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation
import Combine

protocol DreamDetailService {
    func fetchDreamDetailPublisher(id: String) -> AnyPublisher<DreamDetail, Error>
    func deleteDream(id: String) -> AnyPublisher<Void, Error>
}

final class RealDreamDetailService: DreamDetailService {
    private let client = APIClient.shared
    
    func fetchDreamDetailPublisher(id: String) -> AnyPublisher<DreamDetail, Error> {
        let req = client.request("/dreams/\(id)", method: "GET", body: nil)
        return client.run(Envelope<DreamDetailDTO>.self, with: req)
            .tryMap { env in
                // 200/201만 허용 (백엔드 규칙에 맞게 조절)
                guard (200...201).contains(env.status) else {
                    throw URLError(.badServerResponse)
                }
                return env.data.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
    private struct EmptyDTO: Decodable {} // 비어있는 data용
    
    func deleteDream(id: String) -> AnyPublisher<Void, Error> {
        let req = client.request("/dreams/\(id)", method: "DELETE")
        
        return client.run(Envelope<EmptyDTO>.self, with: req)
            .tryMap { env in
                guard (200...299).contains(env.status) else {
                    throw URLError(.badServerResponse)
                }
                return ()   // Void 반환
            }
            .eraseToAnyPublisher()
    }
}
