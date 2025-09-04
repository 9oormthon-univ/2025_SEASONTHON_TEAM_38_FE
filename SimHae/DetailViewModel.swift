//
//  DetailViewModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/5/25.
//

import Foundation
import Combine

struct DreamDetailDTO: Decodable {
    let dreamId: String
    let dreamDate: String?
    let createdAt: String?
    let title: String
    let emoji: String
    let category: String
    let summary: String
    let interpretation: String
    let suggestion: String
}

// 앱에서 쓸 도메인 모델 (Date로 파싱)
struct DreamDetail: Equatable {
    let id: String
    let dreamDate: Date?
    let createdAt: Date?
    let title: String
    let emoji: String
    let category: String
    let summary: String
    let interpretation: String
    let suggestion: String
}

extension DreamDetailDTO {
    func toDomain() -> DreamDetail {
        let dayFormatter = DateFormatter()
        dayFormatter.calendar = Calendar(identifier: .gregorian)
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.dateFormat = "yyyy-MM-dd"
        
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        
        return DreamDetail(
            id: dreamId,
            dreamDate: self.dreamDate.flatMap { dayFormatter.date(from: $0) },
            createdAt: self.createdAt.flatMap { iso.date(from: $0) },
            title: title,
            emoji: emoji,
            category: category,
            summary: summary,
            interpretation: interpretation,
            suggestion: suggestion
        )
    }
}

protocol DreamDetailService {
    func fetchDreamDetailPublisher(id: String) -> AnyPublisher<DreamDetail, Error>
}

// 실제 서버용 예시
final class RealDreamDetailService: DreamDetailService {
    private let client = APIClient.shared
    
    func fetchDreamDetailPublisher(id: String) -> AnyPublisher<DreamDetail, Error> {
        let req = client.request("/dreams/\(id)", method: "GET", body: nil)
        
        // 인증이 있으면:
        // req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        //        return URLSession.shared.dataTaskPublisher(for: req)
        //            .map(\.data)
        //            .decode(type: ResponseEnvelope<DreamDetailDTO>.self, decoder: decoder)
        //            .map { $0.data.toDomain() }
        //            .eraseToAnyPublisher()
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
    
    // 서버가 공통 envelope로 내려준다고 가정
    private struct ResponseEnvelope<T: Decodable>: Decodable {
        let status: Int
        let message: String
        let data: T
    }
}

@MainActor
final class DreamDetailViewModel: ObservableObject {
    @Published var detail: DreamDetail?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let dreamId: String
    private let service: DreamDetailService
    private var bag = Set<AnyCancellable>()

    init(dreamId: String, service: DreamDetailService = RealDreamDetailService()) {
        self.dreamId = dreamId
        self.service = service
    }

    func fetch() {
        if detail != nil { return }    // 중복 호출 방지 (원하면 제거)
        isLoading = true
        errorMessage = nil

        service.fetchDreamDetailPublisher(id: dreamId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] detail in
                self?.detail = detail
            }
            .store(in: &bag)
    }

    func retry() { detail = nil; fetch() }
}
