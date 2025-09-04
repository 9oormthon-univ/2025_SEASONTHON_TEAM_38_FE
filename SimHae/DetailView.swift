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
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteDialog = false
    
    // 커스텀 이니셜라이저
        init(vm: DreamDetailViewModel) {
            _vm = StateObject(wrappedValue: vm)
        }
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let detail = vm.detail {
                    ScrollView {
                        VStack {
                            let koDateStyle = Date.FormatStyle.dateTime
                                .year().month().day().weekday(.wide)
                                .locale(Locale(identifier: "ko_KR"))
                            
                            Text(
                                detail.dreamDate?.formatted(koDateStyle)
                                ?? "꿈 날짜 미정"
                            )
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.top, 12)
                            
                            Text(detail.emoji)
                                .font(.system(size: 40))
                                .padding(.top, 48)
                                .padding(.bottom, 8)
                            
                            Text(detail.title)
                                .font(.title3.bold())
                                .foregroundStyle(Color(hex: "#E8D9FF"))
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 24)
                            
                            Text(detail.summary)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color(hex: "#E8D9FF"))
                                .padding(.horizontal)
                                .padding(.bottom, 24)
                            
                            Text("꿈 카테고리")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "#9963FF"))
                                .padding(.top, 32)
                            
                            Text("일상 반영 꿈")
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
                                .padding()
                            
                            Text("낮 동안의 경험이나 생각이 꿈속에 그대로 혹은 부분적으로 재현된 꿈")
                                .font(.caption)
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
                                .padding()
                                .padding(.bottom, 24)
                            
                            Text("해파리의 제안")
                                .padding(32)
                            
                            Image(systemName: "tortoise.fill")
                                .foregroundStyle(Color(hex: "#E8D9FF"))
                            
                            Text(detail.suggestion)
                                .multilineTextAlignment(.leading)
                                .font(.body)
                                .foregroundStyle(Color(hex: "#E8D9FF"))
                                .padding(28)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(Color(hex: "#7534E4").opacity(0.2))
                                )
//                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(LinearGradient(colors: [Color(hex: "#E8D9FF"), Color(hex: "#5F21CC"), Color(hex: "#E8D9FF")], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
//                                )
                                .padding(.horizontal, 18)
                                .padding(.top, 36)
                        }
                    }
                }
            }
        }
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
                dismiss() //삭제 기능 추가
            }
        } message: {
            Text("한 번 삭제하면 되돌릴 수 없어요.")
        }

    }
    
}

// MARK: - Preview
#Preview {
    NavigationStack {
        DetailView(vm: .preview())
    }
    .preferredColorScheme(.dark)
}

// MARK: - Dummy Service
final class DummyDreamDetailService: DreamDetailService {
    func fetchDreamDetailPublisher(id: String) -> AnyPublisher<DreamDetail, Error> {
        let dto = DreamDetailDTO(
            dreamId: "1",
            dreamDate: "2025-08-26",
            createdAt: "2025-08-26T10:15:00Z",
            title: "철판 아이스크림을 만드는 꿈",
            emoji: "🍦",
            category: "일상 반영 꿈",
            summary: "꿈에서 철판 아이스크림을 만들고 있었고, 그 과정에서 즐거움과 함께 압박감을 느꼈습니다.",
            interpretation: """
            이 꿈은 당신의 삶에서 즐거움과 스트레스가 동시에 존재하는 복잡한 감정을 반영합니다.
            """,
            suggestion: """
            오늘 하루는 자신을 위한 시간을 조금이라도 가지세요.
            """
        )
        let model = dto.toDomain()
        return Just(model)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

extension DreamDetailViewModel {
    static func preview() -> DreamDetailViewModel {
        let vm = DreamDetailViewModel(
            dreamId: "1",
            service: DummyDreamDetailService()
        )
        vm.detail = DreamDetail(
            id: "1",
            dreamDate: Date(),
            createdAt: Date(),
            title: "프리뷰 꿈",
            emoji: "🌙",
            category: "테스트 카테고리",
            summary: "이건 프리뷰용 요약이에요",
            interpretation: "프리뷰용 해석 텍스트입니다.",
            suggestion: "프리뷰 제안 텍스트입니다."
        )
        return vm
    }
}
