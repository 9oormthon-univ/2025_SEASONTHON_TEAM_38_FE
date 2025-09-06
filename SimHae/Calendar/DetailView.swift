//
//  DetailView.swift
//  SimHae
//
//  Created by 홍준범 on 9/5/25.
//

import SwiftUI
import Combine

struct DetailView: View {
    @StateObject private var vm: DreamDetailViewModel
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteDialog = false
    
    // 커스텀 이니셜라이저
    init(vm: DreamDetailViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    var body: some View {
        ZStack {
            Image("DetailViewImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        ScrollView {
            VStack(spacing: 20) {
                if let detail = vm.detail {
                    ScrollView {
                        VStack {
                            let koDateStyle = Date.FormatStyle.dateTime
                                .year().month().day().weekday(.wide)
                                .locale(Locale(identifier: "ko_KR"))
                            
                            Text(
                                "\(detail.dreamDate?.formatted(koDateStyle) ?? "날짜 없음")의 꿈"
                            )
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .padding(.top, 32)
                            
                            Text(detail.emoji)
                                .font(.system(size: 40))
                                .padding(.top, 48)
                                .padding(.bottom, 8)
                                .shadow(color: .purple.opacity(0.8), radius: 12, x: 0, y: 0)
                            // 추가로 바깥쪽 부드럽게 퍼짐
                                .shadow(color: .purple.opacity(0.4), radius: 24, x: 0, y: 0)
                            
                            Text(detail.title)
                                .font(.title3.bold())
                                .foregroundStyle(Color(hex: "#E8D9FF"))
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 32)
                            
                            Text(detail.content)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color(hex: "#E8D9FF"))
                                .padding(.horizontal)
                                .padding(.bottom, 24)
                            
                            Text("꿈 카테고리")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "#9963FF"))
                                .padding(.top, 32)
                            
                            Text(detail.categoryName)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(8)
                                .foregroundStyle(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 100, style: .circular)
                                        .fill(Color(hex: "#9963FF").opacity(0.3))
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
                                                    lineWidth: 0.5
                                                )
                                        )
                                )
                                .padding(.top, 8)
                                .padding(.bottom, 12)
                            
                            Text(detail.categoryDescription)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color(hex: "FFFFFF").opacity(0.6))
                                .padding(.horizontal, 100)
                                .padding(.bottom, 48)
                            
                            Text("꿈 속 무의식 분석")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.top, 36)
                            
                            Text(detail.interpretation)
                                .font(.body)
                                .foregroundStyle(Color(hex: "#E8D9FF"))
                                .multilineTextAlignment(.leading)
                                .padding(28)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(Color(hex: "#7534E4").opacity(0.2))
                                )
                            //                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(LinearGradient(colors: [Color(hex: "#E8D9FF"), Color(hex: "#5F21CC"), Color(hex: "#E8D9FF")], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                            //                                )
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                .padding(.bottom, 24)
                            
                            Text("해파리의 제안")
                                .padding(.top, 48)
                                .padding(.bottom, 16)
                            
                            Image("jellyCha")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                            
                            Text(detail.suggestion)
                                .foregroundStyle(Color(hex: "#E8D9FF"))
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .padding(28)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(Color(hex: "#FFFFFF").opacity(0.1))
                                )
                            //                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(LinearGradient(colors: [Color(hex: "#E8D9FF"), Color(hex: "#5F21CC"), Color(hex: "#E8D9FF")], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                            //                                )
                                .padding(.horizontal, 16)
                                .padding(.top, 36)
                        }
                    }
                } else {
                    ProgressView().tint(.white)
                }
            }
        }
        .onAppear { vm.fetch() }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
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
                    showDeleteDialog = true
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(hex: "#B184FF"))
                        .padding(.trailing, 8)
                }
            }
        }
        .alert("꿈을 삭제하시겠어요?", isPresented: $showDeleteDialog) {
            Button("아니요", role: .cancel) {
                
            }
            Button("네", role: .destructive) {
//                vm.delete {
//                    dismiss() //삭제 기능 추가
//                    NotificationCenter.default.post(name: .dreamDeleted, object: nil)
//                }
//                 // 삭제 후 다시 조회할 날짜(상세에 있던 날짜가 제일 정확)
                let dateToReload = vm.detail?.dreamDate ?? calendarViewModel.selectDate

                vm.delete {
                    Task { @MainActor in
                        calendarViewModel.reloadDay(dateToReload)  // ← 한 방에 끝
                        dismiss()
                    }
                }
            }
        } message: {
            Text("한 번 삭제하면 되돌릴 수 없어요.")
        }
    }
}
}

extension Notification.Name {
    static let dreamDeleted = Notification.Name("dreamDeleted")
}
