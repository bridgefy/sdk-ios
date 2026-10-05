//
//  LiveActivityWidgetLiveActivity.swift
//  LiveActivityWidget
//
//  Created by Francisco on 05/10/26.
//

import ActivityKit
import WidgetKit
import SwiftUI
import BridgefySDK

struct BridgefyLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BLEActivityAttributes.self) { context in
            HStack {
                Image(systemName: "dot.radiowaves.left.and.right")
                Text("Bridgefy active")
                Spacer()
                Text("\(context.state.connectedDevices) devices")
                    .monospacedDigit()
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text("\(context.state.connectedDevices) connected devices")
                }
            } compactLeading: {
                Image(systemName: "dot.radiowaves.left.and.right")
            } compactTrailing: {
                Text("\(context.state.connectedDevices)")
            } minimal: {
                Image(systemName: "dot.radiowaves.left.and.right")
            }
        }
    }
}
