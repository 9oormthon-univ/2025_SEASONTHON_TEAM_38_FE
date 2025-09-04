//
//  AnalyzeView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct AnalyzeView: View {
    var body: some View {
        ZStack {
            
            Image("CalendarBackgroundVer2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .top)
            
            Text("This is Analyze view")
        }
    }
}
#Preview {
    AnalyzeView()
}
