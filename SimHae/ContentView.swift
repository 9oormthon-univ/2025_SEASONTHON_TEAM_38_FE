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
    @StateObject private var analyzeVM = AnalyzeViewModel()
    
    @State private var sessionVM: DreamSessionViewModel?
    
    @State private var tabSelection: TabBarItem = .home
    
    @EnvironmentObject var route: NavigationRouter
    
    var body: some View {
        TabView(selection: $tabSelection) {
            if tabSelection == .home {
                HomeView()
                    .ignoresSafeArea(.keyboard)
                    .navigationBarBackButtonHidden()
            }
            else if tabSelection == .analysis {
                AnalyzeView(vm: analyzeVM)
                    .ignoresSafeArea(.keyboard)
                    .navigationBarBackButtonHidden()
            }
            else if tabSelection == .calendar {
                CalendarTotalView()
                    .environmentObject(calendarVM)
                    .ignoresSafeArea(.keyboard)
                    .navigationBarBackButtonHidden()
            }
        }
        .overlay {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack(spacing: 42) {
                        Image(tabSelection == .home ? "home-white" : "home-purple")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(tabSelection == .home ? Color(hex: "#843CFF") : Color(hex: "#FFFFFF").opacity(0.6))
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                                    .frame(width: 64, height: 64)
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    tabSelection = .home
                                }
                            }
                        Image(tabSelection == .calendar ? "calendar-white" : "calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(tabSelection == .calendar ? Color(hex: "#843CFF") : Color(hex: "#FFFFFF").opacity(0.6))
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                                    .frame(width: 64, height: 64)
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    tabSelection = .calendar
                                }
                            }
                        Image(tabSelection == .analysis ?"cloud-white" : "cloud-purple" )
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(tabSelection == .analysis ? Color(hex: "#843CFF") : Color(hex: "#FFFFFF").opacity(0.6))
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                                    .frame(width: 64, height: 64)
                                
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    tabSelection = .analysis
                                        
                                }
                            }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 28)
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                            .fill(Color(hex: "FFFFFF").opacity(0.2))
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#E8D9FF"),
                                        Color(hex: "#7534E4"),
                                        Color(hex: "#E8D9FF")
                                    ]),
                                    startPoint: .topTrailing,
                                    endPoint: .bottomLeading
                                ),
                                lineWidth: 0.7
                            )
                    )
                    
                    Spacer()
                    
                    Image(systemName: "plus")
                        .frame(width: 70, height: 70)
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(.white)
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
                                    lineWidth: 0.7
                                )
                        )
                        .onTapGesture {
                            route.push(to: .add)
                        }
                    Spacer()
                }
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .ignoresSafeArea(.keyboard)
    }
}

enum DreamRoute: Hashable {
    case add, loading, summary, interpretation, suggestion
}

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
}
