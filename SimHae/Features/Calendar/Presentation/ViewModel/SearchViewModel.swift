//
//  SearchViewModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/6/25.
//

import Foundation
import Combine



// MARK: - ViewModel

final class SearchViewModel: ObservableObject {
    // INPUT
    @Published var query: String = ""

    // OUTPUT
    @Published var results: [DreamRowUI] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    /// 사용자가 결과를 탭했을 때 호출(예: 날짜 이동/상세 진입)
    private let onPick: (DreamRowUI) -> Void

    private let repo: SearchRepositoryProtocol
    private var bag = Set<AnyCancellable>()
    private let minCharacters: Int

    /// - Parameters:
    ///   - repo: 검색 저장소
    ///   - onPick: 결과 선택 시 콜백
    ///   - minCharacters: 최소 검색 글자 수(기본 2)
    init(
        repo: SearchRepositoryProtocol,
        onPick: @escaping (DreamRowUI) -> Void,
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
    func select(_ item: DreamRowUI) {
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
