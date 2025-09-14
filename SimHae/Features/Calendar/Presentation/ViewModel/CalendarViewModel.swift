//
//  CalendarViewModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import Foundation
import Combine

final class CalendarViewModel: ObservableObject {
    
    @Published var monthEmojiByDay: [String: String] = [:]   // "yyyy-MM-dd" -> emoji
    
    @Published var searchQuery: String = ""
    @Published private(set) var searchResults: [DreamRowUI] = []   // 전역 검색 결과
    private var lastIssuedQuery: String?   // ← 늦게 도착한 응답 무시용
    
    func resetSearch() {
            lastIssuedQuery = nil
            searchQuery = ""
            searchResults = []
            isLoading = false
            errorMessage = nil
        }

    private let minSearchLength = 2  // 서버가 1자에서 400 주므로 2자로 제한
    var isSearchQueryTooShort: Bool {
        let t = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return !t.isEmpty && t.count < minSearchLength
    }
    var searchResultsSorted: [DreamRowUI] {
        searchResults.sorted { $0.createdAt > $1.createdAt }
    }

    private let dayKeyDF: DateFormatter = {
        let f = DateFormatter()
        f.locale = .init(identifier: "en_US_POSIX")
        f.calendar = .init(identifier: .gregorian)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    var dreamsForSelected: [DreamRowUI] {
        itemsByDate[key(selectDate)] ?? []
    }

    // NEW: 검색 파이프라인(디바운스)
    private func bindSearch() {
        $searchQuery
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } // 선택
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] q in
                self?.handleSearchInput(q)
            }
            .store(in: &cancellables)
    }
    
    private func handleSearchInput(_ q: String) {
        let trimmed = q.trimmingCharacters(in: .whitespacesAndNewlines)

        // 입력 없음 → 결과 비움 (폴백 없음)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }

        // 너무 짧으면 호출하지 않고 결과 비움
        guard trimmed.count >= minSearchLength else {
            searchResults = []
            return
        }

        // 정상 검색
        search(keyword: trimmed)
    }
    
    func search(keyword: String) {
           isLoading = true
           errorMessage = nil
           let issued = keyword
           lastIssuedQuery = issued

           service.searchDreams(keyword: keyword)
               .receive(on: DispatchQueue.main)
               .sink { [weak self] completion in
                   guard let self else { return }
                   self.isLoading = false
                   if case .failure(let err) = completion {
                       // 현재 쿼리와 다르면(이미 리셋/변경) 무시
                       guard self.lastIssuedQuery == issued else { return }
                       self.errorMessage = err.localizedDescription
                       self.searchResults = []
                   }
               } receiveValue: { [weak self] rows in
                   guard let self else { return }
                   // 현재 쿼리와 다르면(이미 리셋/변경) 무시
                   guard self.lastIssuedQuery == issued else { return }
                   self.searchResults = rows
               }
               .store(in: &cancellables)
       }
    
    // 날짜 → 키
    private func key(_ d: Date) -> String { dayKeyDF.string(from: d) }
    
    // 셀에서 쓸 이모지
    func emojiForDate(_ date: Date) -> String? {
        monthEmojiByDay[key(date)]
    }
    
    func hasDream(on date: Date) -> Bool {
            // 월 이모지 캐시에 있거나, 이미 불러온 일별 데이터가 존재하면 true
            if monthEmojiByDay[key(date)] != nil { return true }
            return !(itemsByDate[key(date)]?.isEmpty ?? true)
        }
    
    // 현재 보이는 월(현재 currentDate 기준) 전체 이모지 로드
    func fetchMonthEmojisForVisibleMonth() {
        let cal = Calendar(identifier: .gregorian)
        let y = cal.component(.year, from: currentDate)
        let m = cal.component(.month, from: currentDate)
        
        service.fetchMonthEmojis(year: y, month: m)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let err) = completion { self?.errorMessage = err.localizedDescription }
            } receiveValue: { [weak self] dict in
                self?.monthEmojiByDay = dict
            }
            .store(in: &cancellables)
    }
    
    // 월 이동 시 호출해도 됨
    func didChangeMonth(to offset: Int) {
        currentDate = getCurrentMonth(addingMonth: offset)
        fetchMonthEmojisForVisibleMonth()
    }
    
    private let service: CalendarDreamService
    
    init(service: CalendarDreamService) {
        self.service = service
        bindSearch()   //NEW
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let cal = Calendar.current
    
    @Published var currentDate: Date = Date()
    @Published var currentMonth: Int = 0
    @Published var selectDate: Date = Date()
    
    @Published var itemsByDate: [String: [DreamRowUI]] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var selectedYear: Int = Calendar.current.component(.year, from: .now)
    @Published var selectedMonth: Int = Calendar.current.component(.month, from: .now)
    
    // 현재 캘린더에 보이는 month 구하는 함수
    func getCurrentMonth(addingMonth: Int) -> Date {
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: addingMonth, to: Date()
        ) else { return Date()}
        
        return currentMonth
    }
    
    //해당 월의 모든 날짜들을 DataValue 배열로 만들어주는 함수, 모든 날짜를 배열로 만들어야 Grid에서 보여주기 가능
    func extractDate(currentMonth: Int) -> [DateValue] {
        let calendar = Calendar.current
        
        //getCurrentMonth 가 리턴한 month 구해서 currentMonth로
        let currentMonth = getCurrentMonth(addingMonth: currentMonth)
        
        //currentMonth가 리턴한 month의 모든 날짜 구하기
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    //
    func getYearAndMonthString(currentDate: Date) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM"
        formatter.locale = Locale(identifier: "ko_KR")
        
        let date = formatter.string(from: currentDate)
        return date.components(separatedBy: " ")
    }
    
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isSelectedEmpty: Bool {
        (itemsByDate[key(selectDate)]?.isEmpty ?? true)
    }
    
    var emptyMessageForSelected: String {
        if isToday(selectDate) {
            return "오늘 기록된 꿈이 없어요"
        } else {
            return "\(formatKoreanDate(selectDate))에 기록된 꿈이 없어요"
        }
    }
    
    /// "2025년 8월 13일" 같은 한국어 날짜 포맷
        func formatKoreanDate(_ date: Date) -> String {
            let df = DateFormatter()
            df.calendar = .init(identifier: .gregorian)
            df.locale = .init(identifier: "ko_KR")
            df.dateFormat = "yyyy년 M월 d일"
            return df.string(from: date)
        }
    
    /// 셀 하이라이트에 쓸 보라색 불투명도
        func highlightOpacity(for date: Date) -> Double {
            if isSameDay(date1: date, date2: selectDate) { return 0.6 }
            if isToday(date) { return 0.2 }
            return 0.0
        }
    
    func didTap(date: Date) {
        selectDate = date
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            fetchIfNeeded(for: date) // 평상시만 서버 호출
        } else {
            // 검색 모드: 날짜 무관, 아무 것도 하지 않음 (또는 search(keyword: q)로 재요청해도 무방)
        }
    }
    
    
    func fetchIfNeeded(for date: Date, force: Bool = false) {
        let k = key(date)
        if !force {
                if let cached = itemsByDate[k], !cached.isEmpty {
                    // 캐시가 있고 비어있지 않으면 스킵
                    return
                }
                // 캐시가 없거나, 캐시가 있지만 비어있으면 내려가서 새로 요청
            }
        
        isLoading = true
        errorMessage = nil
        
        service.fetchDreams(for: date)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] rows in
                self?.itemsByDate[k] = rows
            }
            .store(in: &cancellables)
    }
}

extension Date {
    //현재 월의 날짜를 Date 배열로 만들어주는 함수
    func getAllDates() -> [Date] {
        // 현재날짜 캘린더 가져오기
        let calendar = Calendar.current
        // 현재 월의 첫 날 구하기 -> 일자를 지정하지 않고 year과 month만 구하기 때문에, 그해, 그달의 첫날을 이렇게 구할 수 있음
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        // range의 각각의 날짜를 date로 맵핑해서 배열로
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        return range.compactMap { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: startDate) ?? Date()
        }
    }
}

extension CalendarViewModel {
    var dreamsForSelectedSorted: [DreamRowUI] {
        (itemsByDate[key(selectDate)] ?? []).sorted { $0.createdAt > $1.createdAt }
    }
}

extension CalendarViewModel {
    func invalidateDay(_ date: Date) {
        itemsByDate[key(date)] = nil
    }
}

extension CalendarViewModel {
    @MainActor
    func reloadDay(_ date: Date) {
        // 캐시 비우고
        itemsByDate[key(date)] = nil
        // 해당 날짜 리스트 강제 새로고침
        fetchIfNeeded(for: date, force: true)
        // 월 이모지도 갱신(마지막 카드 삭제/추가 반영)
        fetchMonthEmojisForVisibleMonth()
    }
}
