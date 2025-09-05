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
    let createdAt: String // "2025-08-10T10:00:00"
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
                          let iso   = ISO8601DateFormatter()
                          iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                return env.data.compactMap { dto in
                    // dreamDate는 필수로 파싱 실패 시 드롭
                                  guard let dDate = dayDF.date(from: dto.dreamDate) else { return nil }
                                  let cAt = iso.date(from: dto.createdAt) // 실패하면 nil
                    return DreamRowUI(
                        id: String(dto.dreamId),
                        title: dto.title,
                        summary: dto.content,
                        emoji: dto.emoji,
                        dreamDate: dDate,
                        createdAt: date
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
        let ym = Self.ymDF.string(from: baseDate) // "2025-08"
        
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
                // dict: "yyyy-MM-dd" -> "🕊️"
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
}

final class CalendarViewModel: ObservableObject {
    
    @Published var monthEmojiByDay: [String: String] = [:]   // "yyyy-MM-dd" -> emoji
    private let dayKeyDF: DateFormatter = {
        let f = DateFormatter()
        f.locale = .init(identifier: "en_US_POSIX")
        f.calendar = .init(identifier: .gregorian)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
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
    
    var dreamsForSelected: [DreamRowUI] {
        itemsByDate[key(selectDate)] ?? []
    }
    
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
        /// - 선택된 날짜: 0.6
        /// - 오늘(선택 안됨): 0.2
        /// - 그 외: 0.0
        func highlightOpacity(for date: Date) -> Double {
            if isSameDay(date1: date, date2: selectDate) { return 0.6 }
            if isToday(date) { return 0.2 }
            return 0.0
        }
    
    /// 셀 탭 시 호출 (필요하면 여기서 백엔드 fetch)
    func didTap(date: Date) {
        selectDate = date
        fetchIfNeeded(for: date)
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
