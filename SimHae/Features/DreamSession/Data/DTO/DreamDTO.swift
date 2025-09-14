//
//  DreamDTO.swift
//  SimHae
//
//  Created by 홍준범 on 9/14/25.
//

import Foundation

struct CreateDreamAllDTO: Decodable {
    struct Restate: Decodable {
        let emoji: String
        let title: String
        let content: String
        let categoryName: String
        let categoryDescription: String
    }
    struct Unconscious: Decodable {
        let analysis: String
    }
    struct Suggestion: Decodable {
        let suggestion: String
    }
    let restate: Restate
    let unconscious: Unconscious
    let suggestion: Suggestion
    
    func toDomain() -> (DreamRestate, DreamInterpretation, [String]) {
        let restate = DreamRestate(
            emoji: restate.emoji,
            title: restate.title,
            content: restate.content,
            category: restate.categoryName,
            categoryDescription: restate.categoryDescription
        )
        let interp = DreamInterpretation(
            title: "해석",
            detail: unconscious.analysis
        )
        let actions = [suggestion.suggestion]
        return (restate, interp, actions)
    }
}
