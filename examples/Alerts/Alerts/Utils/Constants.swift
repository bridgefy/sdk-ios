//
//  Constants.swift
//  Remote Control
//
//  Created by Danno on 8/18/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import Foundation

let sectionTimeInterval: TimeInterval = 20*60
let adminPassword = "offline"
let appTintColor = #colorLiteral(red: 0.9294117647, green: 0.2352941176, blue: 0.3725490196, alpha: 1)
let appDisabledColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)

struct StoryboardSegues {
    static let setName = "setName"
}

struct PacketKeys {
    static let id = "id"
    static let sender = "username"
    static let platform = "platform"
    static let date = "date"
    static let text = "text"
    static let command = "command"
    static let image = "image"
    static let color = "color"
    static let content = "ct"
}

struct Sound {
    static let length: TimeInterval = 4.0
    static let fileName = "sound"
    static let ext = "mp3"
}

struct StoredValues {
    static let username = "username"
}

struct NotificationNames {
    static let userReady = "userReady"
    static let networkChange = "netstatechangednotification"
}
