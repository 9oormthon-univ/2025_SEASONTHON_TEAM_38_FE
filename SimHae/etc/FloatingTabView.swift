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
    
//    var color: Color {
//        switch self {
//        case .home: return .red
//        case .calendar: return .green
//        case .analysis: return .blue
//        case .addDream: return .yellow
//        }
//    }
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
