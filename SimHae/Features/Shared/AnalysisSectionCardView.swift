//
//  AnalysisSectionCardView.swift
//  SimHae
//
//  Created by 홍준범 on 9/18/25.
//

import Foundation
import SwiftUI

struct AnalysisSectionCard: View {
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
                Text(text.splitWord())
                    .font(.pretendard(.thin, size: 16))
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
