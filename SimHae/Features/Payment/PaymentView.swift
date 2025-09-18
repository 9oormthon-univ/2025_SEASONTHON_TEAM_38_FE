//
//  PaymentView.swift
//  SimHae
//
//  Created by 홍준범 on 9/18/25.
//

import SwiftUI

struct PaymentView: View {
    @Environment(\.dismiss) private var dismiss
    
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
        
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack(spacing: 12) {
                    Image(.token1)
                        .resizable()
                        .frame(width: 80, height: 80)
                    
                    Text("광고 시청하고\n무료로 조개 1개 얻기")
                        .foregroundStyle(Color(hex: "#E8D9FF"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(hex: "#B184FF"))
                        .padding(.trailing, 16)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(hex: "#9963FF").opacity(0.2))
                )
                VStack(alignment: .leading, spacing: 8) {
                    Text("조개 구매하기")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("*조개 1개당 꿈 해몽 1회입니다.")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#E8D9FF")).opacity(0.5)
                }
                .padding(.top, 24)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ShellCard(title: "조개 한 주먹 (5개)", price: "900원", oldPrice: nil, image: "token2")
                                       ShellCard(title: "조개 주머니 (20개)", price: "2,900원", oldPrice: "3,600원", image: "token3")
                                       ShellCard(title: "조개 바구니 (50개)", price: "5,900원", oldPrice: "9,000원", image: "token4")
                                       ShellCard(title: "조개 상자 (100개)", price: "9,900원", oldPrice: "18,000원", image: "token5")
                }
                
                Text("이용권 구매하기")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.top, 24)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    PaymentCard(title: "1개월 무제한", price: "4,900원", oldPrice: nil, image: "Rainbow")
                                        PaymentCard(title: "1년 무제한", price: "49,000원", oldPrice: "59,800원", image: "Rainbow")
                }
                
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(Color(hex: "#B184FF"))
                        .padding(.leading, 12)
                }
            }
        }
        .navigationTitle("결제하기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PaymentView()
        .preferredColorScheme(.dark)
}

private struct ShellCard: View {
    let title: String
    let price: String
    let oldPrice: String?
    let image: String
    
    var body: some View {
        VStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            Text(title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(hex: "#E8D9FF").opacity(0.7))
            
            HStack {
                if let old = oldPrice {
                    Text(old)
                        .font(.caption2)
                        .strikethrough(color: Color(hex: "843CFF"))
                        .foregroundStyle(Color(hex: "#E8D9FF").opacity(0.5))
                }
                
                Text(price)
                    .font(.headline)
                    .foregroundStyle(Color(hex: "#E8D9FF"))
            }
        }
        .padding(16)
        .frame(width: 170, height: 190)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: "#7534E4").opacity(0.15))
        )
        
        
    }
}

private struct PaymentCard: View {
    let title: String
    let price: String
    let oldPrice: String?
    let image: String
    
    var body: some View {
        VStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            Text(title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            
            HStack {
                if let old = oldPrice {
                    Text(old)
                        .font(.caption2)
                        .strikethrough()
                        .foregroundStyle(.gray)
                }
                
                Text(price)
                    .font(.headline)
                    .foregroundStyle(Color(hex: "#843CFF"))
            }
        }
        .padding(16)
        .frame(width: 170, height: 160)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: "#7534E4").opacity(0.15))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#E8D9FF"),
                            Color(hex: "#7534E4"),
                            Color(hex: "#E8D9FF")
                        ]),
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    ),
                    lineWidth: 0.7
                )
        )
        
        
    }
}
