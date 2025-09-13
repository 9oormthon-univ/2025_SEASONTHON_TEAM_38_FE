//
//  SearchViewModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/6/25.
//

import Foundation
import Combine

// MARK: - DTO (API 응답 스키마)

struct DreamsListResponse: Codable {
    let status: Int
    let message: String
    let data: [DreamDTO]
}

struct DreamDTO: Codable {
    let dreamId: Int
    let title: String
    let emoji: String?
    let summary: String
    let category: String
    let createdAt: String
}

// MARK: - UI 모델

struct SearchItem: Identifiable {
    let id: Int              // dreamId
    let title: String
    let subtitle: String
    let date: Date
    let emoji: String?
}

// MARK: - Repository Protocol

protocol SearchRepositoryProtocol {
    func search(keyword: String, completion: @escaping (Result<[SearchItem], Error>) -> Void)
}

// MARK: - API Repository 구현

final class APISearchRepository: SearchRepositoryProtocol {
    private let api = APIClient.shared
    
    func search(keyword: String, completion: @escaping (Result<[SearchItem], Error>) -> Void) {
        // 1. URLRequest 생성
        var comps = URLComponents(url: api.baseURL.appendingPathComponent("/dreams"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "keyword", value: keyword)
        ]
        guard let url = comps.url else {
            completion(.success([]))
            return
        }
        let req = URLRequest(url: url)
        
        // 2. run()으로 API 호출
        api.run(DreamsListResponse.self, with: req)
            .sink(receiveCompletion: { result in
                if case let .failure(err) = result {
                    DispatchQueue.main.async {
                        completion(.failure(err))
                    }
                }
            }, receiveValue: { response in
                let inDF = DateFormatter()
                inDF.locale = Locale(identifier: "ko_KR")
                inDF.timeZone = TimeZone(secondsFromGMT: 0)
                inDF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                let outDF = DateFormatter()
                outDF.locale = Locale(identifier: "ko_KR")
                outDF.dateFormat = "yyyy.MM.dd (E) HH:mm"
                
                let items = response.data.map { dto -> SearchItem in
                    let date = inDF.date(from: dto.createdAt) ?? Date()
                    return SearchItem(
                        id: dto.dreamId,
                        title: dto.title,
                        subtitle: "\(outDF.string(from: date)) · \(dto.summary)",
                        date: date,
                        emoji: dto.emoji
                    )
                }
                DispatchQueue.main.async {
                    completion(.success(items))
                }
            })
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - ViewModel

final class SearchViewModel: ObservableObject {
    // INPUT
    @Published var query: String = ""

    // OUTPUT
    @Published var results: [SearchItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    /// 사용자가 결과를 탭했을 때 호출(예: 날짜 이동/상세 진입)
    private let onPick: (SearchItem) -> Void

    private let repo: SearchRepositoryProtocol
    private var bag = Set<AnyCancellable>()
    private let minCharacters: Int

    /// - Parameters:
    ///   - repo: 검색 저장소
    ///   - onPick: 결과 선택 시 콜백
    ///   - minCharacters: 최소 검색 글자 수(기본 2)
    init(
        repo: SearchRepositoryProtocol,
        onPick: @escaping (SearchItem) -> Void,
        minCharacters: Int = 2
    ) {
        self.repo = repo
        self.onPick = onPick
        self.minCharacters = minCharacters

        // 🔎 입력 디바운스 → 검색
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] q in
                self?.search(keyword: q)
            }
            .store(in: &bag)
    }

    /// 키보드의 "검색" 제출 액션
    func commitSearch() {
        search(keyword: query)
    }

    /// 리스트에서 항목을 탭
    func select(_ item: SearchItem) {
        onPick(item)
    }

    // MARK: - Private

    private func search(keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minCharacters else {
            // UX: 최소 글자 수 미만이면 비우고 에러도 초기화
            if !results.isEmpty { results = [] }
            if errorMessage != nil { errorMessage = nil }
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        repo.search(keyword: trimmed) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let items):
                    self.results = items
                case .failure(let err):
                    self.results = []
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
}

// MARK: - TimeZone helper

private extension TimeZone {
    static var utc: TimeZone { TimeZone(secondsFromGMT: 0)! }
}
