//
//  QuoteVaultWidgetLiveActivity.swift
//  QuoteVaultWidget
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct QuoteVaultWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct QuoteVaultWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: QuoteVaultWidgetAttributes.self) { context in
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

extension QuoteVaultWidgetAttributes {
    fileprivate static var preview: QuoteVaultWidgetAttributes {
        QuoteVaultWidgetAttributes(name: "World")
    }
}

extension QuoteVaultWidgetAttributes.ContentState {
    fileprivate static var smiley: QuoteVaultWidgetAttributes.ContentState {
        QuoteVaultWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: QuoteVaultWidgetAttributes.ContentState {
         QuoteVaultWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: QuoteVaultWidgetAttributes.preview) {
   QuoteVaultWidgetLiveActivity()
} contentStates: {
    QuoteVaultWidgetAttributes.ContentState.smiley
    QuoteVaultWidgetAttributes.ContentState.starEyes
}
