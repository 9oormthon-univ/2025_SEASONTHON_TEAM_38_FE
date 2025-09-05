//
//  ContentView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingAdd = false
    @StateObject private var calendarVM = CalendarViewModel(service: RealCalendarDreamService())
    
    @State private var tabSelection: TabBarItem = .home
    var body: some View {
        FloatingTabContainerView(selection: $tabSelection, calendarViewModel: calendarVM) {
            HomeView()
                .tabBarItem(tab: .home, selection: $tabSelection)
            CalendarTotalView(calendarViewModel: calendarVM)
                .tabBarItem(tab: .calendar, selection: $tabSelection)
            AnalyzeView()
                .tabBarItem(tab: .analisys, selection: $tabSelection)
        }
    }
}

#Preview {
    ContentView()
}

enum DreamRoute: Hashable {
    case add, loading, summary, interpretation, suggestion
}
