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
                AnalyzeView()
                    .ignoresSafeArea(.keyboard)
                    .navigationBarBackButtonHidden()
            }
            else if tabSelection == .calendar {
                CalendarTotalView(calendarViewModel: calendarVM)
                    .ignoresSafeArea(.keyboard)
                    .navigationBarBackButtonHidden()
            }
        }
        .overlay {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack {
                        Image(systemName: "house.fill")
                            .frame(width: 64, height: 64)
                            .font(.system(size: 22))
                            .background(
                                Circle()
                                    .fill(tabSelection == .home ? Color(hex: "#843CFF") : Color(hex: "#FFFFFF").opacity(0.6))
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                            )
                            .foregroundStyle(tabSelection == .home ? .white : Color(hex: "#843CFF"))
                            .frame(width: 64, height: 64)
                            .foregroundStyle(.red)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    tabSelection = .home
                                }
                            }
                        Image(systemName: "calendar")
                            .frame(width: 64, height: 64)
                            .font(.system(size: 22))
                            .background(
                                Circle()
                                    .fill(tabSelection == .calendar ? Color(hex: "#843CFF") : Color(hex: "#FFFFFF").opacity(0.6))
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                            )
                            .foregroundStyle(tabSelection == .calendar ? .white : Color(hex: "#843CFF"))
                            .frame(width: 64, height: 64)
                            .foregroundStyle(.red)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    tabSelection = .calendar
                                }
                            }
                        Image(systemName: "cloud")
                            .frame(width: 64, height: 64)
                            .font(.system(size: 22))
                            .background(
                                Circle()
                                    .fill(tabSelection == .analysis ? Color(hex: "#843CFF") : Color(hex: "#FFFFFF").opacity(0.6))
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                                
                            )
                            .foregroundStyle(tabSelection == .analysis ? .white : Color(hex: "#843CFF"))
                                    
                            .frame(width: 64, height: 64)
                            .foregroundStyle(.red)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    tabSelection = .analysis
                                        
                                }
                            }
                    }
                    .padding(12)
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
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
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

#Preview {
    ContentView()
}

enum DreamRoute: Hashable {
    case add, loading, summary, interpretation, suggestion
}
