//
//  CalendarView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct CalendarTotalView: View {
    @State private var isShowingDateChangeSheet: Bool = false
    @ObservedObject var calendarViewModel: CalendarViewModel
    @State private var query = ""
    @State private var showSearch = false
    @StateObject private var searchVM: SearchViewModel
    
    init(calendarViewModel: CalendarViewModel) {
        _calendarViewModel = ObservedObject(wrappedValue: calendarViewModel)
        
        let repo = APISearchRepository()
            _searchVM = StateObject(
                wrappedValue: SearchViewModel(repo: repo) { item in
                    calendarViewModel.didTap(date: item.date)
                }
            )
    }
    
    private var weekday: [String] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                
                Image("CalendarBackgroundVer2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(edges: .top)
                
                ScrollView {
                    VStack {
                        Button {
                            showSearch = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(Color(hex: "#FFFFFF"))
                                Text("꿈 내용으로 검색하기")
                                    .foregroundStyle(Color(hex: "#FFFFFF").opacity(0.7))
                                    .textInputAutocapitalization(.never)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(RoundedRectangle(cornerRadius: 30, style: .circular).fill(Color(hex: "#843CFF").opacity(0.1))
                            )
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
                            .padding(.horizontal, 16)
                            .padding(.top)
                            .padding(.bottom)
                        }
                        
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
                                    } label: {
                                        DreamCard(date: item.dreamDate.formatted(.dateTime.year().month().day().weekday(.wide).locale(Locale(identifier: "ko_KR"))), title: item.title, summary: item.summary, emoji: item.emoji ?? "🌙")
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
                .scrollIndicators(.never)
                .onAppear {
                    print("📅 CalendarTotalView appeared")
                    // ✅ 초기 로딩: 월별 + 선택된 날짜 데이터
                    calendarViewModel.fetchMonthEmojisForVisibleMonth()
                    calendarViewModel.fetchIfNeeded(for: calendarViewModel.selectDate, force: calendarViewModel.isToday(calendarViewModel.selectDate))
                }
                .onChange(of: calendarViewModel.selectDate) { newDate in
                    calendarViewModel.fetchIfNeeded(for: newDate, force: calendarViewModel.isToday(newDate))
                }
                //나중에 이거 없으면 뷰 반영 안되는지 테스트 해보기
                //            .onReceive(NotificationCenter.default.publisher(for: .dreamDeleted)) { _ in
                //                // ✅ 삭제 알림 받으면 해당 날짜 데이터 새로고침
                //                calendarViewModel.itemsByDate.removeValue(forKey: calendarViewModel.selectDateKey)
                //                calendarViewModel.fetchIfNeeded(for: calendarViewModel.selectDate, force: true)
                //                calendarViewModel.fetchMonthEmojisForVisibleMonth()
                //            }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}

struct DreamCard: View {
    let date: String
    let title: String
    let summary: String
    let emoji: String
    
    var body: some View {
        HStack(spacing: 24) {
            //이모지 + 글로우
            Text(emoji)
                .font(.system(size: 28))
                .shadow(color: .purple.opacity(0.8), radius: 12, x: 0, y: 0)
            // 추가로 바깥쪽 부드럽게 퍼짐
                .shadow(color: .purple.opacity(0.4), radius: 24, x: 0, y: 0)
                .padding(.leading, 12)
            //텍스트 영역
            VStack(alignment: .leading, spacing: 6) {
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.gray)
                Text(title)
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.white)
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
            // 1) 어두운 배경 그라데이션 (예: #1A1A1A → #0E0E0E)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#1A1A1A"), Color(hex: "#0E0E0E")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            // 2) 테두리 그라데이션 (E8D9FF → 5F21CC → E8D9FF)
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
            // 3) 얇은 안쪽 하이라이트(유리 느낌)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .inset(by: 1)
                        .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
                        .blendMode(.overlay)
                )
        )
        .padding(.horizontal, 4)
    }
}

struct YearMonthHeaderView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    @Binding var isShowingDateChangeSheet: Bool
    
    var body: some View {
        HStack {
            Text("\(calendarViewModel.getYearAndMonthString(currentDate: calendarViewModel.currentDate)[0])년 \(calendarViewModel.getYearAndMonthString(currentDate: calendarViewModel.currentDate)[1])")
                .font(.title3.bold())
            
            Button(action: {
                isShowingDateChangeSheet.toggle()
            }, label: {
                Image(systemName: "chevron.down")
                    .foregroundStyle(.white)
            })
        }
    }
}

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
            DragGesture()
                .onChanged { gesture in
                    self.offset = gesture.translation
                }
                .onEnded { gesture in
                    let calender = Calendar.current
                    let selectYear = calender.component(.year, from: calendarViewModel.currentDate)
                    let selectMonth = calender.component(.month, from: calendarViewModel.currentDate)
                    let presentMonth = calender.component(.month, from: Date())
                    
                    if gesture.translation.width < -20 {
                        if selectMonth == presentMonth {
                            
                        } else {
                            calendarViewModel.currentMonth += 1
                            calendarViewModel.selectedMonth += 1
                        }
                    } else if gesture.translation.width > 20 {
                        if selectYear == 2024 && selectMonth == 1 {
                        } else {
                            calendarViewModel.currentMonth -= 1
                            calendarViewModel.selectedMonth -= 1
                        }
                    }
                    self.offset = CGSize()
                }
        )
    }
}

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
                        .fill(Color(hex: "#FFFFFF").opacity(0.2))            // 선 색/투명도
                        .frame(height: 0.5)
                        .offset(x: 0, y: y)
                }
            }
            .allowsHitTesting(false) // 선이 터치 방해하지 않도록
        }
    }
}

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
                        .padding(.horizontal, 10)   // 좌우 여백
                        .padding(.vertical, 2)                // 동그라미 크기
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

//#Preview {
//    CalendarView()
//}
