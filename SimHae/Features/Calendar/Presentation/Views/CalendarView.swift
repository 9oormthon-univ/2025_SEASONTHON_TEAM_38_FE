//
//  CalendarView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct CalendarTotalView: View {
    @State private var isShowingDateChangeSheet: Bool = false
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    
    @FocusState private var isSearching
    @State private var isbackgroundBlur: Bool = false
    
    private var weekday: [String] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        VStack {
            Image(.appLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 18)
                .padding(.top, 24)

            ScrollView(.vertical,
                       showsIndicators: false) {
                VStack {
                    searchBar
                        .padding(.top, 20)
                    YearMonthHeaderView(calendarViewModel: calendarViewModel, isShowingDateChangeSheet: $isShowingDateChangeSheet)
                        .foregroundStyle(.white)
                        .padding(.top, 8)
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CalendarView(calendarViewModel: calendarViewModel, weekday: weekday)
                        .padding(.horizontal, 16)
                    
                    if calendarViewModel.dreamsForSelected.isEmpty {
                        Text(calendarViewModel.emptyMessageForSelected)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.top, 16)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(calendarViewModel.dreamsForSelected) { item in
                                NavigationLink {
                                    DetailView(vm: DreamDetailViewModel(dreamId: item.id))
                                        .environmentObject(calendarViewModel)
                                } label: {
                                    DreamCard(date: item.dreamDate.formatted(.dateTime.year().month().day().weekday(.wide).locale(Locale(identifier: "ko_KR"))), title: item.title, summary: item.content, emoji: item.emoji ?? "🌙")
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
            }
                       .padding(.bottom, 28)
            .onAppear {
                print("🟣 CalendarTotalView VM:", ObjectIdentifier(calendarViewModel),
                      "selected:", calendarViewModel.selectDate)
                print("📅 CalendarTotalView appeared")
                // 초기 로딩: 월별 + 선택된 날짜 데이터
                calendarViewModel.fetchMonthEmojisForVisibleMonth()
                calendarViewModel.fetchIfNeeded(for: calendarViewModel.selectDate, force: calendarViewModel.isToday(calendarViewModel.selectDate))
            }
            .onChange(of: calendarViewModel.selectDate) { newDate in
                calendarViewModel.fetchIfNeeded(for: newDate, force: calendarViewModel.isToday(newDate))
            }
            //.padding(.horizontal, 16) 얘가 뷰를 자꾸 늘었다 줄였다함.
        }
        .background{
            Image("CalendarBackgroundVer2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .top)
        }
        .blur(radius: isbackgroundBlur ? 20 : 0)
        .onChange(of: isSearching) { newValue in
            withAnimation {
                isbackgroundBlur = newValue        // ← toggle() 말고 값 그대로 반영
            }
            if !newValue {
                calendarViewModel.resetSearch()    // ← 키보드 내려가면 검색어/결과 초기화
            }
        }
        .overlay {
            if isSearching {
                Color.black.opacity(0.25)
                               .ignoresSafeArea()
                               .onTapGesture { withAnimation { isSearching = false } }
                               .transition(.opacity)
                               .zIndex(0)

                
                VStack(spacing: 0) {
                    // 헤더
                    Image(.appLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 18)
                        .padding(.top, 24)

                    searchBar
                        .padding(.top, 20)

                    // 검색 결과만 렌더
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            if calendarViewModel.searchIsLoading {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.top, 24)

                            } else {
                                let q = calendarViewModel.searchQuery

                                if q.isEmpty {
                                    Text("검색어를 입력해 주세요")
                                        .foregroundStyle(.white.opacity(0.6))
                                        .padding(.top, 24)

                                } else if calendarViewModel.isSearchQueryTooShort {
                                    Text("최소 2자 이상 입력해 주세요")
                                        .foregroundStyle(.white.opacity(0.6))
                                        .padding(.top, 24)

                                } else {
                                    let results = calendarViewModel.searchResultsSorted
                                    if results.isEmpty {
                                        Text("검색 결과가 없어요")
                                            .foregroundStyle(.white.opacity(0.6))
                                            .padding(.top, 24)
                                    } else {
                                        ForEach(results) { item in
                                            NavigationLink {
                                                DetailView(vm: DreamDetailViewModel(dreamId: item.id))
                                            } label: {
                                                DreamCard(
                                                    date: item.dreamDate.formatted(
                                                        .dateTime.year().month().day().weekday(.wide)
                                                            .locale(Locale(identifier: "ko_KR"))
                                                    ),
                                                    title: item.title,
                                                    summary: item.content,
                                                    emoji: item.emoji ?? "🌙"
                                                )
                                                .contentShape(Rectangle())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.top, 8)
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") {
                    isSearching = false   // onChange에서 resetSearch 호출됨
                }
            }
        }
    }
    
    private var searchBar: some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color(hex: "#FFFFFF"))
                TextField("꿈 내용으로 검색하기", text: $calendarViewModel.searchQuery)
                    .focused($isSearching)
                    .foregroundStyle(Color(hex: "#FFFFFF").opacity(0.7))
                    .textInputAutocapitalization(.never)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 30, style: .circular).fill(Color(hex: "#843CFF").opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 30, style: .circular)
                .stroke(LinearGradient(
                    gradient: Gradient(colors:[
                        Color(hex: "#E8D9FF"),
                        Color(hex: "#7534E4"),
                        Color(hex: "#E8D9FF")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                        lineWidth: 1)
            )
            .frame(width: 360)
            .padding(.top)
        }
    }
}

// MARK: 꿈 기록 카드
struct DreamCard: View {
    let date: String
    let title: String
    let summary: String
    let emoji: String
    
    var body: some View {
        HStack(spacing: 24) {
            Text(emoji)
                .font(.system(size: 28))
                .shadow(color: .purple.opacity(0.8), radius: 12, x: 0, y: 0)
                .shadow(color: .purple.opacity(0.4), radius: 24, x: 0, y: 0)
                .padding(.leading, 12)
            VStack(alignment: .leading, spacing: 6) {
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.gray)
                Text(title)
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#1A1A1A"), Color(hex: "#0E0E0E")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(hex: "#E8D9FF"), location: 0.0),
                                    .init(color: Color(hex: "#5F21CC"), location: 0.5),
                                    .init(color: Color(hex: "#E8D9FF"), location: 1.0),
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .inset(by: 1)
                        .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
                        .blendMode(.overlay)
                )
        )
        .frame(width: UIScreen.main.bounds.width - 32)
    }
}

// MARK: 달력 커스텀

// 달력 상단 연월 표시
struct YearMonthHeaderView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    @Binding var isShowingDateChangeSheet: Bool
    
    var body: some View {
        HStack {
            
            Button(action: {
                let cal = Calendar.current
                let lowerBound = cal.date(from: DateComponents(year: 2024, month: 1, day: 1))!
                let prevMonth = cal.date(byAdding: .month, value: -1, to: calendarViewModel.currentDate)!
                
                // 2024-01 이전으로는 못 가게
                let isPrevBeforeLower = cal.compare(
                    cal.date(from: cal.dateComponents([.year, .month], from: prevMonth))!,
                    to: lowerBound,
                    toGranularity: .month
                ) == .orderedAscending
                
                guard !isPrevBeforeLower else { return }
                
                withAnimation(.easeInOut) {
                    calendarViewModel.currentMonth -= 1
                    calendarViewModel.selectedMonth -= 1
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
            
            Text("\(calendarViewModel.getYearAndMonthString(currentDate: calendarViewModel.currentDate)[0])년 \(calendarViewModel.getYearAndMonthString(currentDate: calendarViewModel.currentDate)[1])")
                .font(.title3.bold())
            
            // 다음 달 버튼
            Button(action: {
                let cal = Calendar.current
                let now = Date()
                let nextMonth = cal.date(byAdding: .month, value: 1, to: calendarViewModel.currentDate)!
                
                // 미래 달로 넘어가지 않도록(다음달이 오늘보다 이후면 막기)
                let isNextBeyondNow = cal.compare(
                    cal.date(from: cal.dateComponents([.year, .month], from: nextMonth))!,
                    to: cal.date(from: cal.dateComponents([.year, .month], from: now))!,
                    toGranularity: .month
                ) == .orderedDescending
                
                guard !isNextBeyondNow else { return }
                
                withAnimation(.easeInOut) {
                    calendarViewModel.currentMonth += 1
                    calendarViewModel.selectedMonth += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
    }
}

// 달력
struct CalendarView: View {
    
    @State private var offset: CGSize = CGSize()
    @ObservedObject var calendarViewModel: CalendarViewModel
    
    let weekday: [String]
    
    var body: some View {
        VStack {
            WeekdayHeaderView(weekday: weekday)
            DatesGridView(calendarViewModel: calendarViewModel)
        }
        .padding(.top, 20)
        .onChange(of: calendarViewModel.currentMonth) { newOffset in
            calendarViewModel.didChangeMonth(to: newOffset)
        }
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    self.offset = value.translation
                }
                .onEnded { value in
                    let cal = Calendar.current
                    
                    // 현재 드래그 vs 예측 종료 지점(=속도 반영)
                    let dx  = value.translation.width
                    let pdx = value.predictedEndTranslation.width
                    // 더 큰 쪽을 최종 제스처로 채택 (속도 강할수록 pdx가 큼)
                    let finalDx = abs(pdx) > abs(dx) ? pdx : dx
                    
                    // 세로 제스처 무시 (가로 우세만 허용)
                    let dy = value.translation.height
                    guard abs(finalDx) > abs(dy) else { return }
                    
                    // 스와이프 인식 임계값
                    let threshold: CGFloat = 40
                    guard abs(finalDx) > threshold else { return }
                    
                    // 날짜 경계 계산
                    let current = calendarViewModel.currentDate
                    let now = Date() // 오늘
                    let nextMonth = cal.date(byAdding: .month, value: 1, to: current)!
                    let prevMonth = cal.date(byAdding: .month, value: -1, to: current)!
                    let lowerBound = cal.date(from: DateComponents(year: 2024, month: 1, day: 1))!
                    
                    withAnimation(.easeInOut) {
                        if finalDx < 0 {
                            // 미래 달로 넘어가지 않도록(다음달이 오늘보다 이후면 막기)
                            let isNextBeyondNow = cal.compare(
                                cal.date(from: cal.dateComponents([.year, .month], from: nextMonth))!,
                                to: cal.date(from: cal.dateComponents([.year, .month], from: now))!,
                                toGranularity: .month
                            ) == .orderedDescending
                            guard !isNextBeyondNow else { return }
                            
                            calendarViewModel.currentMonth += 1
                            calendarViewModel.selectedMonth += 1
                            
                        } else {
                            // 최소 2024-01 이전으로는 못 가게
                            let isPrevBeforeLower = cal.compare(
                                cal.date(from: cal.dateComponents([.year, .month], from: prevMonth))!,
                                to: lowerBound,
                                toGranularity: .month
                            ) == .orderedAscending
                            guard !isPrevBeforeLower else { return }
                            
                            calendarViewModel.currentMonth -= 1
                            calendarViewModel.selectedMonth -= 1
                        }
                    }
                    self.offset = .zero
                }
        )
    }
}

// 월화수목금토일
struct WeekdayHeaderView: View {
    let weekday: [String]
    var body: some View {
        HStack {
            ForEach(weekday, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white.opacity(0.2))
            }
        }
        .padding(.bottom, 5)
    }
}

// 날짜 그리드
struct DatesGridView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    
    // 7열 고정
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    // 줄 레이아웃(마음에 맞게 숫자만 조절)
    private let rowHeight: CGFloat = 66   // 한 줄(숫자+이모지)의 고정 높이
    private let rowSpacing: CGFloat = 2  // 줄 사이 간격
    
    var body: some View {
        // days를 한 번만 계산해 쓰자
        let days = calendarViewModel.extractDate(currentMonth: calendarViewModel.currentMonth)
        let rows = Int(ceil(Double(days.count) / 7.0))
        
        ZStack(alignment: .topLeading) {
            
            // 날짜 그리드
            LazyVGrid(columns: columns, spacing: rowSpacing) {
                ForEach(days) { value in
                    if value.day != -1 {
                        DateButton(value: value,
                                   calendarViewModel: calendarViewModel,
                                   selectDate: $calendarViewModel.selectDate)
                        .frame(height: rowHeight)                 // ← 줄 높이 고정
                    } else {
                        // 빈 칸도 같은 높이로 채워 레이아웃 유지
                        Color.clear
                            .frame(height: rowHeight)
                    }
                }
            }
            
            // 주 구분선 오버레이
            GeometryReader { geo in
                ForEach(1..<rows, id: \.self) { i in
                    // i번째 줄 아래에 선을 깔자
                    let y = CGFloat(i) * (rowHeight + rowSpacing) - (rowSpacing / 2)
                    
                    Rectangle()
                        .fill(Color(hex: "#FFFFFF").opacity(0.2))
                        .frame(height: 0.5)
                        .offset(x: 0, y: y)
                }
            }
            .allowsHitTesting(false) // 선이 터치 방해하지 않도록
        }
    }
}

// 날짜 버튼
struct DateButton: View {
    var value: DateValue
    @ObservedObject var calendarViewModel: CalendarViewModel
    @Binding var selectDate: Date
    
    private var isSelected: Bool {
        calendarViewModel.isSameDay(date1: value.date, date2: selectDate)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    calendarViewModel.didTap(date: value.date)
                }
            } label: {
                VStack(spacing: 6) {
                    Text("\(value.day)")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 100, style: .circular)
                                .fill(Color(hex: "#843CFF")
                                    .opacity(calendarViewModel.highlightOpacity(for: value.date)))
                        )
                    
                    // 꿈이 있으면 이모지, 없으면 빈 공간 유지
                    Text(calendarViewModel.emojiForDate(value.date) ?? " ")
                        .font(.system(size: 14))
                        .frame(height: 16)
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(value.date > Date())
        }
    }
}

struct KeyboardObserver: ViewModifier {
    @State private var isKeyboardVisible = false
    
    func body(content: Content) -> some View {
        content
            .scrollDisabled(isKeyboardVisible) // 키보드 보이면 스크롤 꺼버림
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                isKeyboardVisible = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                isKeyboardVisible = false
            }
    }
}

extension View {
    func disableScrollWhenKeyboardVisible() -> some View {
        self.modifier(KeyboardObserver())
    }
}
