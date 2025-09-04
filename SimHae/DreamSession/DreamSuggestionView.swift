//
//  DreamSuggestionView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct DreamSuggestionView: View {
    @ObservedObject var vm: DreamSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
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
                    
                    Image(systemName: "tortoise.fill")
                        .foregroundStyle(.white)
                    
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
                        .padding(32)
                    
                    Image(systemName: "tortoise.fill")
                        .foregroundStyle(Color(hex: "#E8D9FF"))
                    
                    ForEach(vm.actions, id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 10) {
                            Text(suggestion)
                                .multilineTextAlignment(.leading)
                                .font(.body)
                                .foregroundStyle(Color(hex: "#E8D9FF"))
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
                    }
                    
                    Spacer()
                    
                    Button("해몽 완료") {
                        dismiss()
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

