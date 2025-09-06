//
//  AddDreamView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI
import Combine

struct AddDreamView: View {
    @ObservedObject var vm: DreamSessionViewModel
  //  @ObservedObject var calendarViewModel: CalendarViewModel
    @State private var showInfo: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelDialog = false
    @State private var showCalendar = false
    @State private var tempDate = Date()
    @FocusState private var isTextFocused: Bool
    @ObservedObject private var speech: SpeechInputViewModel
    @Binding var selectedDate: Date
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject private var route: NavigationRouter
    
    // ✅ 커스텀 init을 공개(internal)로 명시
        init(
            vm: DreamSessionViewModel,
            selectedDate: Binding<Date>,
           // calendarViewModel: CalendarViewModel,
        ) {
            // ObservedObject는 wrappedValue로 세팅하는 편이 안전
            self._vm = ObservedObject(wrappedValue: vm)
            self._selectedDate = selectedDate
          //  self._calendarViewModel = ObservedObject(wrappedValue: calendarViewModel)
            self._speech = ObservedObject(wrappedValue: vm.speech)

        }

    
    private var weekday: [String] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    private var guidanceText: String {
        if vm.canSubmit {
            return ""
        }
        return "20자 이상 입력해주세요."
    }
    
    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                Image("AddDreamBackgroundImage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isTextFocused = false
                        showInfo = false
                        showCalendar = false
                    }
                
                GeometryReader { geo in
                    let w = geo.size.width
                    let d = w * 1.8                 // 원 지름(화면 폭 대비 크기)
                    let exposure: CGFloat = 0.7   // ⬅️ 화면 아래에서 얼마나 올려서 보이게 할지 비율(0~1 추천)
                    
                    Circle()
                        .fill(Color(hex: "#13052A").opacity(0.8))
                        .frame(width: d, height: d)
                    // 화면 하단에 원의 바닥을 맞춘 뒤, 'exposure * d' 만큼 위로 끌어올린다
                        .position(x: w / 2, y: geo.size.height + d * (0.5 - exposure))
                        .ignoresSafeArea()
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "#7534E4").opacity(0.8), lineWidth: 40)
                                .blur(radius: 200)
                            
                        )
                        .shadow(color: Color(hex:" 843CFF").opacity(0.5),
                                radius: 78.9, x:0, y: 0)
                        .background(
                            Circle()
                                .fill(Color.clear)
                                .blur(radius: 50)
                        )
                }
                .allowsHitTesting(false)
                
                VStack {
                    
                    ZStack {
                        
                        Button {
                            tempDate = vm.input.date
                            showCalendar.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundStyle(Color(hex: "#843CFF"))
                                
                                let style = Date.FormatStyle.dateTime
                                    .year().month().day().weekday(.wide)
                                    .locale(Locale(identifier: "ko_KR"))
                                
//                                Text("\(vm.input.date.formatted(style))의 꿈")
                                Text("\(calendarViewModel.selectDate.formatted(style))의 꿈")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .padding(.top, 50)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .top) {
                        if showInfo {
                            Color.black.opacity(0.001)
                                .ignoresSafeArea()
                                .onTapGesture {
                                        showInfo = false
                                        isTextFocused = false
                                }
                            CalloutBubble(message: "꿈과 관련해 떠오르는 현실의 기억이나 상황이 있나요?\n함께 입력하면 더 정확한 해몽을 제공할 수 있어요.").offset(y: 15)
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.28), value: showInfo)
                    .overlay(alignment: .top) {
                        if showCalendar {
                            CalendarCallOutView(calendarViewModel: calendarViewModel, weekday: weekday
                            )
                            .padding(.top , 90)
                            .transition(.opacity)
                            .zIndex(1)
                        }
                    }
                    .animation(.easeInOut(duration: 0.28), value: showCalendar)
                    .allowsHitTesting(true)
                    
                    Spacer().frame(height: 120)
                    ZStack(alignment: .top) {
                        TextField("텍스트로 입력하기...", text: $vm.input.content, axis: .vertical)
                            .focused($isTextFocused)
                            .textFieldStyle(.plain)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .frame(height: 400, alignment: .top)
                            .padding(.horizontal)
                            .padding(.leading, 10)
                            .padding(.top, 20)
                    }
                    Spacer()
                }
                .overlay(alignment: .bottom) {
                    ZStack {
                        HStack {
                            Spacer()
                            Button {
                                //  키보드/포커스 먼저 내리고
                                isTextFocused = false
                                vm.speech.toggleRecording()
                            } label: {
                                Image(systemName: speech.isRecording ? "stop.fill" : "mic")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 32))
                                    .frame(width: 72, height: 72)
                                    .background(
                                        Circle()
                                            .fill(Color.black)
                                            .overlay(
                                                Circle()
                                                    .fill(Color(hex: "#843CFF").opacity(0.7)))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(hex: "#E8D9FF"),
                                                        Color(hex: "#7534E4"),
                                                        Color(hex: "#E8D9FF")
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            }
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                route.push(to: .loading)
                                vm.analyzeDream()
                            } label: {
                                Image(systemName: "arrow.right")
                                    .foregroundStyle(vm.canSubmit ? .white : .gray)
                                    .font(.system(size: 20))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle().fill(
                                            vm.canSubmit ? Color(hex: "#843CFF") : Color(hex: "FFFFFF").opacity(0.1)
                                        )
                                    )
                            }
                            .disabled(!vm.canSubmit)
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.bottom, 24)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showCancelDialog = true
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color(hex: "#B184FF"))
                                .padding(.leading, 8)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("꿈 기록하기")
                            .foregroundStyle(.white)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showInfo.toggle()
                            }
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color(hex: "#B184FF"))
                                .padding(.trailing, 8)
                        }
                    }
                }
                .alert("꿈 입력을 취소하시겠어요?", isPresented: $showCancelDialog) {
                    Button("아니요", role: .cancel) {
                        
                    }
                    Button("네", role: .destructive) {
//                        vm.resetAll(selectedDate: calendarViewModel.selectDate)
                        vm.resetAll(selectedDate: Date()) // ← 오늘 날짜로 초기화
                        calendarViewModel.selectDate = Date() // ← 다음에 들어와도 오늘로 시작하고 싶으면 함께 초기화
                        dismiss()
                    }
                } message: {
                    Text("지금까지 입력한 모든 내용이 삭제돼요.")
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") { isTextFocused = false}
                }
            }
            .overlay(alignment: .bottom) {
                Text(guidanceText)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 120)
                    .frame(maxWidth: .infinity)
                    .animation(.easeInOut(duration: 0.2), value: guidanceText)
                    .allowsHitTesting(false)
            }
            
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .onAppear { vm.input.date = calendarViewModel.selectDate ;
            // AddDreamView.onAppear
            print("🟡 AddDreamView VM:", ObjectIdentifier(calendarViewModel),
                  "selected:", calendarViewModel.selectDate) }
        .onChange(of: calendarViewModel.selectDate) { vm.input.date = $0 }
//        .onChange(of: calendarViewModel.selectDate) { newDate in
//            vm.input.date = newDate
//        }
    }
}

private struct CalloutBubble: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
              ZStack {
                RoundedRectangle(cornerRadius: 100, style: .circular)
                  .fill(.ultraThinMaterial)               // 뒤 배경 블러
                RoundedRectangle(cornerRadius: 100, style: .circular)
                  .fill(Color.white
                    .opacity(0.28))        // 틴트 강화 → 덜 비침
              }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 100, style: .circular)
                    .stroke(Color(hex: "#4512A0").opacity(0.8), lineWidth: 1)
            )
            .padding(.horizontal, 24)
    }
}

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

struct CalendarCallOutView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    
    let weekday: [String]
    
    var body: some View {
        VStack {
            WeekdayHeaderView(weekday: weekday)
            
            DatesGridForCalendarCallOutView(calendarViewModel: calendarViewModel)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                //.fill(Color(hex: "#7534E4").opacity(0.2))
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, 48)
        
    }
}

struct DatesGridForCalendarCallOutView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    // 줄 레이아웃(마음에 맞게 숫자만 조절)
    private let rowHeight: CGFloat = 38   // 한 줄(숫자+이모지)의 고정 높이
    private let rowSpacing: CGFloat = 2 // 줄 사이 간격
    
    var body: some View {
        let days = calendarViewModel.extractDate(currentMonth: calendarViewModel.currentMonth)
        let rows = Int(ceil(Double(days.count) / 7.0))
        
        LazyVGrid(columns: columns, spacing: rowSpacing) {
            ForEach(days) { value in
                if value.day != -1 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            calendarViewModel.didTap(date: value.date)
                        }
                    } label: {
                        Text("\(value.day)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 9)   // 좌우 여백
                            .padding(.vertical, 2)                // 동그라미 크기
                            .background(
                                RoundedRectangle(cornerRadius: 100, style: .circular)
                                    .fill(Color(hex: "#843CFF")
                                        .opacity(calendarViewModel.highlightOpacity(for: value.date)))
                            )
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(value.date > Date())
                    .frame(height: rowHeight)
                }
            }
        }
    }
}
