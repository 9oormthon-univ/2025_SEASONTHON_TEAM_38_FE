//
//  CalendarViewModel.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import Foundation
import Combine

struct DateValue: Identifiable {
    var id: String = UUID().uuidString
    var day: Int
    var date: Date
}

private struct DayDreamDTO: Decodable {
    let dreamId: Int
    let dreamDate: String
    let title: String
    let emoji: String?
    let content: String
    let category: String?
    let createdAt: String
}

struct DreamRowUI: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let emoji: String?
    let dreamDate: Date
    let createdAt: Date
}

protocol CalendarDreamService {
    func fetchDreams(for date: Date) -> AnyPublisher<[DreamRowUI], Error>
    func fetchMonthEmojis(year: Int, month: Int) -> AnyPublisher<[String: String], Error>
    func searchDreams(keyword: String) -> AnyPublisher<[DreamRowUI], Error>
}

final class RealCalendarDreamService: CalendarDreamService {
    private let client = APIClient.shared
    
    // 재사용 가능한 포맷터(생성 비용 ↓)
    private static let dayDF: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.locale = .init(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    // yyyy-MM
    private static let ymDF: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.locale   = .init(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM"
        return f
    }()
    
    private static let iso8601: ISO8601DateFormatter = {
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
        
        print("➡️ [fetchDreams] GET", comps.url!.absoluteString)
        
        let decoder = JSONDecoder()
        return URLSession.shared.dataTaskPublisher(for: req)
            .handleEvents(receiveOutput: { out in
                    let http = out.response as? HTTPURLResponse
                    let code = http?.statusCode ?? -1
                    let raw  = String(data: out.data, encoding: .utf8) ?? "<non-utf8 \(out.data.count) bytes>"
                    print("⬅️ [fetchDreams] status=\(code)")
                    print("   raw:", raw)
                })
            .map(\.data)
            .decode(type: Envelope<[DayDreamDTO]>.self, decoder: JSONDecoder())
            .tryMap { env in
                guard (200...299).contains(env.status) else {
                    throw URLError(.badServerResponse)
                }
                
                let dayDF = Self.dayDF
                        let iso   = Self.iso8601Frac
                
                return env.data.compactMap { dto in
                                guard let dDate = dayDF.date(from: dto.dreamDate) else { return nil }
                                let cAt = iso.date(from: dto.createdAt) ?? dDate
                                return DreamRowUI(
                                    id: String(dto.dreamId),
                                    title: dto.title,
                                    summary: dto.content,
                                    emoji: dto.emoji,
                                    dreamDate: dDate,
                                    createdAt: cAt
                                )
                            }
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
        private static let iso8601Frac: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return f
        }()

    private struct SearchDreamDTO: Decodable {
        let dreamId: Int
        let title: String
        let emoji: String?
        let summary: String?
        let content: String?
        let category: String?
        let createdAt: String

        var summaryText: String {
            // 우선순위: summary > content > ""
            summary ?? content ?? ""
        }
    }
    //날짜 없이 /dreams?keyword=...
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

            print("➡️ [searchDreams] GET", urlc.url!.absoluteString)

            return client.run(Envelope<[SearchDreamDTO]>.self, with: req)
                .tryMap { env in
                    guard (200...299).contains(env.status) else { throw URLError(.badServerResponse) }
                    let iso = Self.iso8601Frac
                    return env.data.map { dto in
                        let created = iso.date(from: dto.createdAt) ?? Date()
                        return DreamRowUI(
                            id: String(dto.dreamId),
                            title: dto.title,
                            summary: dto.summaryText,
                            emoji: dto.emoji,
                            dreamDate: created,           // 검색 응답엔 dreamDate가 없으니 createdAt 기준
                            createdAt: created
                        )
                    }
                }
                .eraseToAnyPublisher()
        }
}

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
