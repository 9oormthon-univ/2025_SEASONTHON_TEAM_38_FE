//
//  AnalyzeViewModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/6/25.
//

import Foundation
import Combine

// MARK: - ViewModel
@MainActor
final class AnalyzeViewModel: ObservableObject {
    @Published var summary: UnconsciousAnalyzeSummary?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var notEnoughData = false
    let minimumCount = 7

    private let client = APIClient.shared
    private var bag = Set<AnyCancellable>()
    private let endpointPath: String

    init(endpointPath: String = "/ai/dreams/unconscious") {
        self.endpointPath = endpointPath
    }

    // 최초 진입 시 한 번만
    func loadIfNeeded() {
        guard !isLoading, summary == nil, !notEnoughData else { return }
        load()
    }

    // 당겨서 새로고침 등 강제 재조회
    func reload() {
        bag.removeAll()
        summary = nil
        errorMessage = nil
        notEnoughData = false
        load()
    }

    func load() {
        guard !isLoading else { return }        // 중복 방지
        isLoading = true
        errorMessage = nil
        
        let req = client.request(endpointPath, method: "POST")

        URLSession.shared.dataTaskPublisher(for: req)
            .tryMap { output -> (Int, Data) in
                let code = (output.response as? HTTPURLResponse)?.statusCode ?? -1
                // 응답 로깅
                print("⬅️ Response \(code) from \(self.endpointPath)")
                if let raw = String(data: output.data, encoding: .utf8) {
                    print("Raw body:", raw)
                } else {
                    print("Raw body: <non-utf8 \(output.data.count) bytes>")
                }
                return (code, output.data)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case let .failure(err) = completion,
                   self.errorMessage == nil,
                   !self.notEnoughData {
                    self.errorMessage = "분석을 불러오지 못했어요: \(err.localizedDescription)"
                }
            } receiveValue: { [weak self] (code, data) in
                guard let self else { return }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                if (200...299).contains(code) {
                    do {
                        let dto = try decoder.decode(UnconsciousAnalyzeResponseDTO.self, from: data)
                        guard (200...201).contains(dto.status) else {
                            self.errorMessage = dto.message
                            return
                        }
                        self.summary = dto.toDomain()
                    } catch {
                        self.errorMessage = "응답 해석 실패: \(error.localizedDescription)"
                    }
                } else if code == 400 {
                    if let err = try? decoder.decode(ErrorEnvelope.self, from: data) {
                        if err.message.contains("최소 7개") || err.message.contains("최소 7개의 꿈") {
                            self.notEnoughData = true
                        } else {
                            self.errorMessage = err.message
                        }
                    } else {
                        self.errorMessage = "요청이 올바르지 않습니다(400)."
                    }
                } else {
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
