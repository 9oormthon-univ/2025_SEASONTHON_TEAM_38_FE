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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    
    @EnvironmentObject private var route: NavigationRouter
    
    var body: some View {
        
        ZStack {
            Image("DreamSessionBackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if let interp = vm.interpretation {
                VStack(spacing: 24) {
                    Text("꿈 속 무의식 분석")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.top, 36)
                        .padding(.bottom, 28)
                    
                    Text(interp.detail)
                        .font(.body)
                        .foregroundStyle(Color(hex: "#E8D9FF"))
                        .multilineTextAlignment(.center)
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(hex: "#7534E4").opacity(0.2))
                        )
                        .padding(.horizontal, 18)
                        .padding(.top, 36)
                    
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
