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
    @State private var goSuggestion = false
    @Environment(\.dismiss) private var dismiss
    
    // 부모에서 주는 콜백들
      var onNext: () -> Void                 // 제안 화면으로
      var onHome: (() -> Void)? = nil        // 홈(루트)로 (옵션)
      var onBack:  (() -> Void)? = nil
    
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
//                        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(LinearGradient(colors: [Color(hex: "#E8D9FF"), Color(hex: "#5F21CC"), Color(hex: "#E8D9FF")], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
//                                 )
                        .padding(.horizontal, 18)
                        .padding(.top, 36)
                    
                    Spacer()
                    
                    Button("다음으로") {
                        onNext()     
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "5F21CC").opacity(0.3).blur(radius: 40))
                    .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color(hex: "4312A0"), lineWidth: 1.5))
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24) // 홈 인디케이터와 간격
//                    .navigationDestination(isPresented: $goSuggestion) {
//                        DreamSuggestionView(vm: vm)
//                    }
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
                    onHome?()
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
