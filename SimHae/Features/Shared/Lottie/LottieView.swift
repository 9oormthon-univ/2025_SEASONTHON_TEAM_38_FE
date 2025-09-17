//
//  LottieView.swift
//  SimHae
//
//  Created by 홍준범 on 9/17/25.
//

import Foundation
import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop
    
    func makeUIView(context: Context) -> Lottie.LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.play()
        
        return animationView
    }
    
    typealias UIViewType = Lottie.LottieAnimationView
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        //
    }
}
