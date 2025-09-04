//
//  TabView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

enum TabItem: String, CaseIterable {
    case home
    case calendar
    case analysis
}

struct TabView: View {
    
    @Binding var tab: TabItem
    
    var body: some View {
        HStack(spacing: 14) {
            ForEach(TabItem.allCases, id: \.self) { t in
                Button {
                    tab = t
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    ZStack {
                        Circle()
                            .fill(tab == t ? Color(hex: "#843CFF") : Color(hex: "#FFFFFF").opacity(0.6))
                            .frame(width: 56, height: 56)
                            .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                        Image(systemName: icon(for: t))
                            .font(.system(size: 22))
                            .foregroundStyle(tab == t ? .white : Color(hex: "#843CFF"))
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(label(for: t)))
                .accessibilityAddTraits(tab == t ? .isSelected : [])
            }
        }
        .padding(.horizontal, 12
        )
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 100, style: .circular)
                .fill(Color.black) // 뒷내용 가리는 불투명 배경
                .overlay(
                    RoundedRectangle(cornerRadius: 100, style: .circular)
                        .fill(Color(hex: "#FFFFFF").opacity(0.2))
                )
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
                            lineWidth: 1.5
                        )
                )
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: tab)
    }
    
    func icon(for t: TabItem) -> String {
        switch t { case .home: "house"; case .calendar: "calendar"; case .analysis: "cloud"}
    }
    
    func label(for t: TabItem) -> String {
        switch t { case .home: "홈"; case .calendar: "캘린더"; case .analysis: "분석" }
    }
}
