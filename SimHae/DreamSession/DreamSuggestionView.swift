//
//  DreamSuggestionView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct DreamSuggestionView: View {
    @ObservedObject var vm: DreamSessionViewModel
//    @ObservedObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var route: NavigationRouter
    
    var body: some View {
        ZStack {
            Image("DreamSessionBackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
     
            if vm.actions.isEmpty {
                VStack {
                    Text("해파리의 제안")
                        .foregroundStyle(.white)
                        .padding(32)
                    
                    Image("jellyCha")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("추천을 불러오는 중이거나 아직 없어요")
                        .multilineTextAlignment(.leading)
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(hex: "#7534E4").opacity(0.2))
                        )
                        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(LinearGradient(colors: [Color(hex: "#E8D9FF"), Color(hex: "#5F21CC"), Color(hex: "#E8D9FF")], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        .padding(.horizontal, 18)
                        .padding(.top, 36)
                }
            } else {
                VStack(spacing: 12) {
                    Text("해파리의 제안")
                        .foregroundStyle(.white)
                        .padding(32)
                    
                    Image("jellyCha")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding()
                    
                    ForEach(vm.actions, id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 10) {
                            Text(suggestion)
                                .multilineTextAlignment(.center)
                                .font(.body)
                                .foregroundStyle(Color(hex: "#E8D9FF"))
                                .padding(28)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(Color(hex: "#FFFFFF").opacity(0.1))
                                )
                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(LinearGradient(colors: [Color(hex: "#E8D9FF"), Color(hex: "#5F21CC"), Color(hex: "#E8D9FF")], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                                         )
                                .padding(.horizontal, 18)
                                .padding(.top, 36)
                        }
                    }
                    
                    Spacer()
                    
                    Button("해몽 완료") {
                        let d = Calendar.current.startOfDay(for: vm.input.date) // ✨ 기록한 날짜
                        calendarViewModel.invalidateDay(d)                      // 1) 캐시 무효화
                        calendarViewModel.fetchIfNeeded(for: d, force: true)    // 2) 강제 리프레시
                        calendarViewModel.selectDate = d                        // 3) (선택) 해당 날짜로 유지
                        vm.resetAll(selectedDate: d)
                        route.removeAll()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "5F21CC").opacity(0.3).blur(radius: 40))
                    .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color(hex: "4312A0"), lineWidth: 1.5))
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24) // 홈 인디케이터와 간격
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

//#Preview {
//    DreamSuggestionView()
//}

