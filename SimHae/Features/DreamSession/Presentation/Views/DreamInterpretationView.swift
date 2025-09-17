//
//  DreamInterpretationView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI
import Combine

struct DreamInterpretationView: View {
    @ObservedObject var vm: DreamSessionViewModel
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    
    @EnvironmentObject private var route: NavigationRouter
    
    var body: some View {
        
        ZStack {
            Image("DreamSessionBackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if let interp = vm.interpretation, let restate = vm.restate {
                VStack(spacing: 24) {
                    Text("꿈 속 무의식 분석")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.top, 36)
                        .padding(.bottom, 14)
                    
                    Spacer()
                    
                    Text(restate.emoji)
                        .font(.system(size: 40))
                    
                    Text(restate.title)
                        .font(.title3.bold())
                        .foregroundStyle(Color(hex: "#E8D9FF"))
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    if !interp.sections.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(interp.sections.indices, id: \.self) { i in
                                    AnalysisSectionCard(
                                        title: interp.sections[i].title,
                                        text: interp.sections[i].content
                                    )
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                    Spacer()
                    
                    Button("다음으로") {
                        route.push(to: .suggestion)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "5F21CC").opacity(0.3).blur(radius: 40))
                    .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color(hex: "4312A0"), lineWidth: 1.5))
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    route.pop()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(hex: "#B184FF"))
                        .padding(.leading, 8)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let d = Calendar.current.startOfDay(for: vm.input.date)
                    calendarViewModel.invalidateDay(d)
                    calendarViewModel.fetchIfNeeded(for: d, force: true)
                    calendarViewModel.selectDate = d
                    vm.resetAll(selectedDate: d)
                    route.removeAll()
                } label: {
                    Image(systemName: "house.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(hex: "#B184FF"))
                        .padding(.trailing, 8)
                }
            }
        }
    }
}

private struct AnalysisSectionCard: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(hex: "#E8D9FF"))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 100, style: .circular)
                        .fill(Color(hex: "#843CFF").opacity(0.2))
                )
            
            ScrollView(.vertical, showsIndicators: false) {
                Text(text)
                    .font(.body)
                    .foregroundStyle(Color(hex: "#E8D9FF"))
                    .multilineTextAlignment(.leading)
            }
            
        }
        .padding(20)
        .frame(width: 250, height: 220)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(hex: "#7534E4").opacity(0.2))
        )
    }
}
