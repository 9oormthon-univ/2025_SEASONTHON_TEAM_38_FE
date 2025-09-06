//
//  SearchOverlayView.swift
//  SimHae
//
//  Created by 홍준범 on 9/6/25.
//

import SwiftUI

struct SearchOverlayView: View {
    @ObservedObject var vm: SearchViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color(hex: "#FFFFFF"))
                    TextField("꿈 내용으로 검색하기", text: $vm.query)
                        .foregroundStyle(Color(hex: "#FFFFFF").opacity(0.7))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: 30, style: .circular).fill(Color(hex: "#843CFF").opacity(0.1))
                )
                .overlay(RoundedRectangle(cornerRadius: 30, style: .circular)
                    .stroke(LinearGradient(
                        gradient: Gradient(colors:[
                            Color(hex: "#E8D9FF"),
                            Color(hex: "#7534E4"),
                            Color(hex: "#E8D9FF")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                            lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.top)
                .padding(.bottom)
                
                Text("드림카드")
            }
        }
    }
}
//
//#Preview {
//    SearchOverlayView()
//}
