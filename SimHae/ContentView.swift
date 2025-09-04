//
//  ContentView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .home
    @State private var showingAdd = false
    @StateObject private var calendarVM = CalendarViewModel(service: RealCalendarDreamService())
    
    var body: some View {
        NavigationStack {
            switch selectedTab {
            case .home:
                HomeView()
            case .calendar:
                CalendarDetailView(calendarViewModel: calendarVM)
            case .analysis:
                VStack {
                    Image(systemName: "cloud").font(.system(size: 72))
                    Text("분석").font(.title2)
                    Spacer()
                }
            }
            
            HStack {
                TabView(tab: $selectedTab)
                Spacer()
                NavigationLink {
                    AddDreamView(vm: DreamSessionViewModel(service: RealDreamService(), speech: SpeechInputViewModel(speechRecognizer: SpeechRecognizer())
                                                          )
                    )
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
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
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
    }
}

#Preview {
    ContentView()
}
