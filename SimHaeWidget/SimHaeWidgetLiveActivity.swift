//
//  SimHaeWidgetLiveActivity.swift
//  SimHaeWidget
//
//  Created by 홍준범 on 9/18/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SimHaeWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SimHaeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SimHaeWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SimHaeWidgetAttributes {
    fileprivate static var preview: SimHaeWidgetAttributes {
        SimHaeWidgetAttributes(name: "World")
    }
}

extension SimHaeWidgetAttributes.ContentState {
    fileprivate static var smiley: SimHaeWidgetAttributes.ContentState {
        SimHaeWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SimHaeWidgetAttributes.ContentState {
         SimHaeWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SimHaeWidgetAttributes.preview) {
   SimHaeWidgetLiveActivity()
} contentStates: {
    SimHaeWidgetAttributes.ContentState.smiley
    SimHaeWidgetAttributes.ContentState.starEyes
}
