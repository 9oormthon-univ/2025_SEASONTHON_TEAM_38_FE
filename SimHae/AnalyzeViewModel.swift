//
//  AnalyzeViewModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/6/25.
//

import Foundation
import Combine

// MARK: - DTO (서버 응답)

struct UnconsciousAnalyzeResponseDTO: Decodable {
    let status: Int
    let message: String
    let data: Payload
    
    struct Payload: Decodable {
        let title: String
        let analysis: String
        let suggestion: String
        let recentDreams: [String]
    }
}


// MARK: - Domain Model

struct UnconsciousAnalyzeSummary: Equatable {
    let title: String
    let analysis: String
    let suggestion: String
    let recentDreams: [String]
}

extension UnconsciousAnalyzeResponseDTO {
    func toDomain() -> UnconsciousAnalyzeSummary {
        .init(
            title: data.title,
            analysis: data.analysis,
            suggestion: data.suggestion,
            recentDreams: data.recentDreams
        )
    }
}

// 🔹 에러 바디 파싱용(400일 때)
private struct ErrorEnvelope: Decodable {
    let status: Int
    let message: String
}

// MARK: - ViewModel

@MainActor
final class AnalyzeViewModel: ObservableObject {
    // 출력 바인딩
    @Published var summary: UnconsciousAnalyzeSummary?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var notEnoughData = false   // ✅ 7개 미만 안내 화면 노출 여부
        let minimumCount = 7

    // 내부
    private let client = APIClient.shared
    private var bag = Set<AnyCancellable>()
    
    /// 서버 경로(필요 시 바꿔 쓰기)
    private let endpointPath: String
    
    /// - Parameter endpointPath: 기본값 "/ai/unconscious/overall"
    init(endpointPath: String = "/ai/dreams/unconscious") {
            self.endpointPath = endpointPath
        }
    
    func load() {
        isLoading = true
        errorMessage = nil
        notEnoughData = false
        summary = nil
        
        let req = client.request(endpointPath, method: "POST")
        
        // ⛳️ APIClient.run은 4xx에서 throw하니, 여기서는 직접 상태코드 확인
               URLSession.shared.dataTaskPublisher(for: req)
                   .tryMap { output -> (Int, Data) in
                       let code = (output.response as? HTTPURLResponse)?.statusCode ?? -1
                       return (code, output.data)
                   }
                   .receive(on: DispatchQueue.main)
                   .sink { [weak self] completion in
                       guard let self else { return }
                       self.isLoading = false
                       if case let .failure(err) = completion, self.errorMessage == nil, !self.notEnoughData {
                           self.errorMessage = "분석을 불러오지 못했어요: \(err.localizedDescription)"
                       }
                   } receiveValue: { [weak self] (code, data) in
                       guard let self else { return }
                       let decoder = JSONDecoder()
                       decoder.dateDecodingStrategy = .iso8601

                       if (200...299).contains(code) {
                           // 정상
                           do {
                               let dto = try decoder.decode(UnconsciousAnalyzeResponseDTO.self, from: data)
                               // 서버 바디의 status도 200/201인지 체크
                               guard (200...201).contains(dto.status) else {
                                   self.errorMessage = dto.message
                                   return
                               }
                               self.summary = dto.toDomain()
                           } catch {
                               self.errorMessage = "응답 해석 실패: \(error.localizedDescription)"
                           }
                       } else if code == 400 {
                           // 7개 미만 같은 비즈니스 에러
                           if let err = try? decoder.decode(ErrorEnvelope.self, from: data) {
                               // 메시지로 ‘최소 7개’ 감지
                               if err.message.contains("최소 7개의 꿈") || err.message.contains("최소 7개") {
                                   self.notEnoughData = true
                               } else {
                                   self.errorMessage = err.message
                               }
                           } else {
                               self.errorMessage = "요청이 올바르지 않습니다(400)."
                           }
                       } else {
                           // 그 외 상태
                           if let err = try? decoder.decode(ErrorEnvelope.self, from: data) {
                               self.errorMessage = err.message
                           } else {
                               self.errorMessage = "서버 오류(\(code))."
                           }
                       }
                   }
                   .store(in: &bag)
           }
}
