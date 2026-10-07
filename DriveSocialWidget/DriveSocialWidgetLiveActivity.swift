//
//  DriveSocialWidgetLiveActivity.swift
//  DriveSocialWidget
//
//  Created by Oscar Costa on 7/10/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DriveSocialWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DriveSocialWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DriveSocialWidgetAttributes.self) { context in
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

extension DriveSocialWidgetAttributes {
    fileprivate static var preview: DriveSocialWidgetAttributes {
        DriveSocialWidgetAttributes(name: "World")
    }
}

extension DriveSocialWidgetAttributes.ContentState {
    fileprivate static var smiley: DriveSocialWidgetAttributes.ContentState {
        DriveSocialWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DriveSocialWidgetAttributes.ContentState {
         DriveSocialWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DriveSocialWidgetAttributes.preview) {
   DriveSocialWidgetLiveActivity()
} contentStates: {
    DriveSocialWidgetAttributes.ContentState.smiley
    DriveSocialWidgetAttributes.ContentState.starEyes
}
