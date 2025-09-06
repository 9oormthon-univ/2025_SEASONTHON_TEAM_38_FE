//
//  DreamSummaryView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI
import Combine

struct DreamSummaryView: View {
    @ObservedObject var vm: DreamSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    /// 부모가 주는 화면 이동 콜백들
       var onNext: () -> Void                     // 해석 화면으로
       var onHome: (() -> Void)? = nil            // 홈(루트)으로 (옵션)
       var onBack:  (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Image("DreamSessionBackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if let restate = vm.restate {
                
                VStack(spacing: 14) {
                    
                    let style = Date.FormatStyle.dateTime
                        .year().month().day().weekday(.wide)
                        .locale(Locale(identifier: "ko_KR"))
                    
                    Text("\(vm.input.date.formatted(style))의 꿈")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .padding(.top, 24)
                    
                    Spacer()
                    
                    Text(restate.emoji)
                        .font(.system(size: 40))
                    
                    Text(restate.title)
                        .font(.title3.bold())
                        .foregroundStyle(Color(hex: "#E8D9FF"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 32)
                    
                    Text(restate.content)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: "#E8D9FF"))
                        .padding(.horizontal)
                        .padding()
                    
                    Text("꿈 카테고리")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#9963FF"))
                        .padding(.top, 32)
                    
                    Text(restate.category)
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
                    
                    Text(restate.categoryDescription)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: "FFFFFF").opacity(0.6))
                        .padding(.horizontal, 100)
                    
                    Spacer()
                    
                    Button("다음으로") {
                        onNext()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "5F21CC").opacity(0.3).blur(radius: 40))
                    .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color(hex: "4312A0"), lineWidth: 1.5))
                    .foregroundStyle(Color(hex: "B184FF"))
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
