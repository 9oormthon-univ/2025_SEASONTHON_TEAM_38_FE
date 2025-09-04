//
//  HomeView.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        Image("jellyCha")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
    }
}

#Preview {
    HomeView()
}
