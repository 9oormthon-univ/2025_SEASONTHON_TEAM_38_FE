//
//  FloatingTabView.swift
//  SimHae
//
//  Created by 홍준범 on 9/5/25.
//

import SwiftUI

enum TabBarItem: Hashable {
    case home, calendar, analisys
    
    var iconName: String {
        switch self {
        case .home: return "house"
        case .calendar: return "calendar"
        case .analisys: return "cloud"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return .red
        case .calendar: return .green
        case .analisys: return .blue
        }
    }
}

struct FloatingTabView: View {
    let tabs: [TabBarItem]
    
    @Binding var selection: TabBarItem
    @State var localSelection: TabBarItem
    @Namespace private var namespace
    
    var body: some View {
        tabBar
            .onChange(of: selection) { newValue in
                withAnimation(.easeInOut(duration: 0.25)) {
                    localSelection = newValue
                }
            }
    }
}
//
//#Preview {
//    FloatingTabView()
//}

extension FloatingTabView {
    private func tabView(tab: TabBarItem) -> some View {
        VStack {
            Image(systemName: tab.iconName)
                .font(.system(size: 22))
                .foregroundStyle(localSelection == tab ? .white : Color(hex: "#843CFF"))
                .background(
                    Circle()
                        .fill(localSelection == tab ? Color(hex: "#843CFF") : Color(hex: "#FFFFFF").opacity(0.6))
                        .frame(width: 56, height: 56)
                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                )
                .padding()
        }
        .foregroundStyle(localSelection == tab ? .white : Color(hex: "#843CFF"))
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                if localSelection == tab {
                    Circle()
                        .fill(.clear)
                    //                                            .matchedGeometryEffect(id: "backgroundRect", in: namespace)
                }
            }
        )
    }
    
    private var tabBar: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView(tab: tab)
                    .onTapGesture {
                        switchToTab(tab: tab)
                    }
            }
        }
        .padding(8)
        .background(
            Color(hex: "#FFFFFF").opacity(0.2).ignoresSafeArea(edges: .bottom)
        )
        .cornerRadius(80)
        .overlay(
            RoundedRectangle(cornerRadius: 100, style: .circular)
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
                    lineWidth: 1.5
                )
        )
        .frame(width: 220, alignment: .leading)
    }
    
    private func switchToTab(tab: TabBarItem) {
        selection = tab
    }
}

struct FloatingTabContainerView<Content: View>: View {
    @Binding var selection: TabBarItem
    @State private var tabs: [TabBarItem] = []
    let content: Content
    
    init(selection: Binding<TabBarItem>, @ViewBuilder content: () -> Content) {
        //바인딩 프로퍼티라 언더바
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        NavigationStack {
            ZStack() {
                content.ignoresSafeArea()
                
                
            }
            .overlay(alignment: .bottomLeading) {
                FloatingTabView(tabs: tabs, selection: $selection, localSelection: selection).ignoresSafeArea(.keyboard)
                    .padding(.leading, 32)
            }
            .overlay(alignment: .bottomTrailing) {
                FloatingPlusButton(destination:
                                    AddDreamView(
                                        vm: DreamSessionViewModel(
                                            service: RealDreamService(),
                                            speech: SpeechInputViewModel(
                                                speechRecognizer: SpeechRecognizer()
                                            )
                                        )
                                    )
                )
                .padding(.trailing, 32)
                .padding(.bottom, 12)
                .ignoresSafeArea(.keyboard)
            }
            
            .onPreferenceChange(TabBarItemsPreferenceKey.self) { value in
                self.tabs = value
            }
        }
    }
}
    
    struct TabBarItemsPreferenceKey: PreferenceKey {
        static var defaultValue: [TabBarItem] = []
        
        static func reduce(value: inout [TabBarItem], nextValue: () -> [TabBarItem]) {
            value += nextValue()
        }
    }
    
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
    
    struct FloatingPlusButton<Destination: View>: View {
        var destination: Destination
        
        var body: some View {
            NavigationLink  {
                destination
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(.white)
                    .frame(width: 70, height: 70)
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
                                        Color(hex: "#E8D9FF"),   // purple/100
                                        Color(hex: "#7534E4"),   // purple/600
                                        Color(hex: "#E8D9FF")    // purple/100
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

