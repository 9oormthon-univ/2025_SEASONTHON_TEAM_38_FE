//
//  FloatingTabView.swift
//  SimHae
//
//  Created by 홍준범 on 9/5/25.
//

import SwiftUI

enum TabBarItem: Hashable {
    case home, calendar, analysis, addDream
    
    var iconName: String {
        switch self {
        case .home: return "house"
        case .calendar: return "calendar"
        case .analysis: return "cloud"
        case .addDream: return "plus"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return .red
        case .calendar: return .green
        case .analysis: return .blue
        case .addDream: return .yellow
        }
    }
}

//struct FloatingTabView: View {
//    let tabs: [TabBarItem]
//    
//    @Binding var selection: TabBarItem
//    @State var localSelection: TabBarItem
//    @Namespace private var namespace
//    
//    var body: some View {
//        tabBar
//            .onChange(of: selection) { newValue in
//                withAnimation(.easeInOut(duration: 0.25)) {
//                    localSelection = newValue
//                }
//            }
//    }
//}
////
////#Preview {
////    FloatingTabView()
////}
//
//extension FloatingTabView {
//    private func tabView(tab: TabBarItem) -> some View {
//        VStack {
//            Image(systemName: tab.iconName)
//                .font(.system(size: 22))
//                .foregroundStyle(localSelection == tab ? .white : Color(hex: "#843CFF"))
//                .background(
//                    Circle()
//                        .fill(localSelection == tab ? Color(hex: "#843CFF") : Color(hex: "#FFFFFF").opacity(0.6))
//                        .frame(width: 56, height: 56)
//                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
//                )
//                .padding()
//        }
//        .foregroundStyle(localSelection == tab ? .white : Color(hex: "#843CFF"))
//        .padding(.vertical, 8)
//        .background(
//            ZStack {
//                if localSelection == tab {
//                    Circle()
//                        .fill(.clear)
//                }
//            }
//        )
//    }
//    
//    private var tabBar: some View {
//        HStack {
//            ForEach(tabs, id: \.self) { tab in
//                tabView(tab: tab)
//                    .onTapGesture {
//                        switchToTab(tab: tab)
//                    }
//            }
//        }
//        .padding(8)
//        .background(
//            Color(hex: "#FFFFFF").opacity(0.2)
//        )
//        .cornerRadius(80)
//        .overlay(
//            RoundedRectangle(cornerRadius: 100, style: .circular)
//                .stroke(
//                    LinearGradient(
//                        gradient: Gradient(colors: [
//                            Color(hex: "#E8D9FF"),
//                            Color(hex: "#7534E4"),
//                            Color(hex: "#E8D9FF")
//                        ]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    ),
//                    lineWidth: 0.7
//                )
//        )
//        .frame(width: 220, alignment: .leading)
//    }
//    
//    private func switchToTab(tab: TabBarItem) {
//        selection = tab
//    }
//}
//
//struct FloatingTabContainerView<Content: View>: View {
//    @Binding var selection: TabBarItem
//    @State private var tabs: [TabBarItem] = []
//    let content: Content
//    
//    // 🔹 네비게이션 스택 상태
//    //    @State private var path = NavigationPath()
//    @State private var path: [DreamRoute] = []
//    @State private var sessionVM: DreamSessionViewModel?
//    let calendarViewModel: CalendarViewModel
//    
//    
//    init(selection: Binding<TabBarItem>, calendarViewModel: CalendarViewModel, @ViewBuilder content: () -> Content) {
//        //바인딩 프로퍼티라 언더바
//        self._selection = selection
//        self.calendarViewModel = calendarViewModel
//        self.content = content()
//    }
//    
//    var body: some View {
//        NavigationStack(path: $path) {
//            VStack(spacing: 0) {
//                content
//            }
//            .frame(width: UIScreen.main.bounds.width,
//                   height: UIScreen.main.bounds.height)
//            .overlay(alignment: .bottomLeading) {
//                FloatingTabView(tabs: tabs, selection: $selection, localSelection: selection)
//                    .padding(.leading, 28)
//                    .padding(.bottom, 16)
//            }
//            .overlay(alignment: .bottomTrailing) {
//                FloatingPlusButton {
//                    sessionVM?.startNewSession(for: calendarViewModel.selectDate)
//                    path.append(.add)
//                }
//                .padding(.trailing, 20)
//                .padding(.bottom, 12)
//            }
//            
//            .onPreferenceChange(TabBarItemsPreferenceKey.self) { value in
//                self.tabs = value
//            }
//            .navigationDestination(for: DreamRoute.self) { route in
//                if route == .add {
//                    // ✅ 첫 진입 시 지연 생성
//                    let localVM = sessionVM ?? {
//                        let new = DreamSessionViewModel(
//                            service: RealDreamService(),
//                            speech: SpeechInputViewModel(speechRecognizer: SpeechRecognizer())
//                        )
//                        sessionVM = new
//                        return new
//                    }()
//
//
//
//                    AddDreamView(vm: localVM, calendarViewModel: calendarViewModel) {
//                        path.append(.loading)
//                    }
//                    .onAppear {
//                        localVM.startNewSession(for: calendarViewModel.selectDate)
//                    }
//                    
//                } else if let vm = sessionVM {
//                    switch route {
//                    case .loading:
//                        DreamLoadingView(vm: vm) { path.append(.summary) }
//                    case .summary:
//                        DreamSummaryView(vm: vm,
//                                         onNext: { path.append(.interpretation) },
//                                         onHome: {path = .init(); sessionVM = nil}
//                        )
//                        
//                    case .interpretation:
//                        DreamInterpretationView(vm: vm,
//                                                onNext: { path.append(.suggestion) },
//                                                onHome: { path = .init(); sessionVM = nil })
//                    case .suggestion:
//                        DreamSuggestionView(
//                            vm: vm,
//                            onFinish: { path = .init(); sessionVM = nil },
//                            onHome:   { path = .init(); sessionVM = nil }
//                        )
//                    default:
//                        EmptyView()
//                    }
//                    
//                } else {
//                    // vm 없고 .add도 아닌 경우 방어
//                    Color.clear.task { path = .init() }
//                }
//            }
//        }
//        
//    }
//}
//
//
struct TabBarItemsPreferenceKey: PreferenceKey {
    static var defaultValue: [TabBarItem] = []
    
    static func reduce(value: inout [TabBarItem], nextValue: () -> [TabBarItem]) {
        value += nextValue()
    }
}
//
struct TabBarItemViewModifier: ViewModifier {
    let tab: TabBarItem
    @Binding var selection: TabBarItem
    
    func body(content: Content) -> some View {
        content
            .opacity(selection == tab ? 1.0 : 0.0)
            .preference(key: TabBarItemsPreferenceKey.self, value: [tab])
    }
}

extension View {
    func tabBarItem(tab: TabBarItem, selection: Binding<TabBarItem>) -> some View {
        self
            .modifier(TabBarItemViewModifier(tab: tab, selection: selection))
    }
}
//
//struct FloatingPlusButton: View {
//    var action: () -> Void
//    
//    var body: some View {
//        Button(action: action)  {
//            Image(systemName: "plus")
//                .font(.system(size: 28, weight: .light))
//                .foregroundStyle(.white)
//                .frame(width: 70, height: 70)
//                .background(
//                    Circle()
//                        .fill(Color.black)
//                        .overlay(
//                            Circle()
//                                .fill(Color(hex: "#843CFF").opacity(0.7)))
//                )
//                .overlay(
//                    Circle()
//                        .stroke(
//                            LinearGradient(
//                                gradient: Gradient(colors: [
//                                    Color(hex: "#E8D9FF"),
//                                    Color(hex: "#7534E4"),
//                                    Color(hex: "#E8D9FF")
//                                ]),
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            ),
//                            lineWidth: 0.7
//                        )
//                )
//        }
//        .buttonStyle(.plain)
//    }
//}
//
