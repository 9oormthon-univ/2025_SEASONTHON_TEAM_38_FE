//
//  Color+Extension.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)

            let r = Double((int >> 16) & 0xFF) / 255.0
            let g = Double((int >> 8) & 0xFF) / 255.0
            let b = Double(int & 0xFF) / 255.0

            self.init(red: r, green: g, blue: b)
        }
}

extension Font {
    enum PretendardWeight {
        case black
        case bold
        case heavy
        case ultraLight
        case light
        case medium
        case regular
        case semibold
        case thin
        
        var value: String {
            switch self {
            case .black:
                return "Black"
            case .bold:
                return "Bold"
            case .heavy:
                return "ExtraBold"
            case .ultraLight:
                return "ExtraLight"
            case .light:
                return "Light"
            case .medium:
                return "Medium"
            case .regular:
                return "Regular"
            case .semibold:
                return "SemiBold"
            case .thin:
                return "Thin"
            }
        }
    }

    static func pretendard(_ weight: PretendardWeight, size fontSize: CGFloat) -> Font {
        let familyName = "Pretendard"
        let weightString = weight.value

        return Font.custom("\(familyName)-\(weightString)", size: fontSize)
    }
}
